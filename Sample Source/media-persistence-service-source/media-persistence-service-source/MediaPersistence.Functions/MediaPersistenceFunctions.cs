using System;
using System.ComponentModel.Design;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using AutofacOnFunctions.Services.Ioc;
using FunctionAppHelper.Repository;
using System.Web.Http;
using MediaPersistence.Functions.Helpers;
using MediaPersistence.Functions.Commands;
using MediaPersistence.Functions.Common;
using MediaPersistence.Functions.Entities;
using MediaPersistence.Functions.Repositories;
using MediaPersistence.Functions.Helpers.Interfaces;

namespace MediaPersistenceService
{
    public static class MediaPersistenceFunctions
    {
        public static readonly string audience = $"{Environment.GetEnvironmentVariable("audience")}";
        public static readonly string functionName = $"{Environment.GetEnvironmentVariable("FunctionName")}";

        [FunctionName(name: "HealthCheck")]
        public static async Task<IActionResult> HealthCheckAsync(
           [HttpTrigger(authLevel: AuthorizationLevel.Anonymous, "get", Route = "HealthCheck")] HttpRequest req)
        {
            return new OkObjectResult("");
        }

        [FunctionName(name: "SaveImage")]
        public static async Task<IActionResult> RunSaveImageAsync(
            [HttpTrigger(authLevel: AuthorizationLevel.Anonymous, "post", "put", Route ="SaveImage/{application}/{applicationArea}")] HttpRequest req,
            string application, 
            string applicationArea, 
            [Inject] IFunctionRepository functionRepository,
            [Inject] IAuthenticationHelper authenticationHelper,
            [Inject] IMediaRepository mediaRepository)
        {
            try
            {
                if (req == null)
                {
                    return new InternalServerErrorResult();
                }
                var routePrefix = req.Path.Value.Substring(0, req.Path.Value.IndexOf("SaveImage",StringComparison.CurrentCultureIgnoreCase));
                Response_SaveMedia resp = new Response_SaveMedia();
                UserRoleCommand command = new UserRoleCommand { ApplicationAreaName = applicationArea, ApplicationName = application, RoleName = "write" };

                if (!AuthenticateRequest(req, functionRepository, authenticationHelper, ref command))
                {
                    return new UnauthorizedResult();
                }

                MediaMetadata mediaMetadata = new MediaMetadata();
                if (!GetValidatedImage(req, ref mediaMetadata))
                {
                    functionRepository?.Logger.LogInformation($"Image Mime Type or Filename extension invalid. Application: {application} Area: {applicationArea} User: {command.UserPrincipalName}");
                    return new UnauthorizedResult();
                }
                var imageUrl = await (mediaRepository?.SaveAsync(mediaMetadata, command)).ConfigureAwait(false);
                if (req.Headers.ContainsKey("X-Forwarded-Host")) { 

                    resp.link = $"https://{req.Headers["X-Forwarded-Host"]}/{functionName}/{imageUrl}";
                }
                else
                {
                    resp.link = $"{audience}{routePrefix}{imageUrl}";
                }
                return new OkObjectResult(resp);
            }
            catch (Exception ex)
            {
                functionRepository?.Logger.LogError(ex, "Error while saving image {message}: ", ex.Message);
                return new OkObjectResult(value: $"Error while saving the image");
            }
        }
        
        [FunctionName("GetImage")]
        public static async Task<IActionResult> RunGetImageAsync(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "RetrieveImage/{application}/{applicationArea}/{docResourceLink}/{attachmentResourceLink}/{docId}")] HttpRequest req,
            string application, 
            string applicationArea, 
            string docResourceLink,
            string attachmentResourceLink,
            string docId,
            [Inject] IFunctionRepository functionRepository,
            [Inject] IAuthenticationHelper authenticationHelper,
            [Inject] IMediaRepository mediaRepository)
        {
            try
            {
                UserRoleCommand command = new UserRoleCommand { ApplicationAreaName = applicationArea, ApplicationName = application, RoleName = "read" };
                if (!AuthenticateRequest(req, functionRepository, authenticationHelper, ref command))
                {
                    return new UnauthorizedResult();
                }

                byte[] fileContent = await (mediaRepository?.GetAsync(docResourceLink, attachmentResourceLink, docId, command)).ConfigureAwait(false);

                if (fileContent != null)
                {
                    return new FileContentResult(fileContent, "image/jpeg");
                }
                else
                {
                    functionRepository?.Logger.LogInformation($"The requested Application/ApplicationArea does not match the image metadata " +
                        $"{application} - {applicationArea} or the user {command.UserPrincipalName} does not have read permission to the requested Application/Area in BEAS");
                    return new UnauthorizedResult();
                }

            }
            catch (Exception ex)
            {
                functionRepository?.Logger.LogError(ex, "Error getting media with Id {attachmentResourceLink} under doc {docId}: {message}", attachmentResourceLink, docId, ex.Message );
                return new InternalServerErrorResult();
            }

        }

        [FunctionName("GetBlobImage")]
        public static async Task<IActionResult> GetBlobImageAsync(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "RetrieveImage/{application}/{applicationArea}/{docId}")] HttpRequest req,
            string application,
            string applicationArea,
            string docId,
            [Inject] IFunctionRepository functionRepository,
            [Inject] IAuthenticationHelper authenticationHelper,
            [Inject] IMediaRepository mediaRepository)
        {
            try
            {
                var command = new UserRoleCommand { ApplicationAreaName = applicationArea, ApplicationName = application, RoleName = "read" };

                if (!AuthenticateRequest(req, functionRepository, authenticationHelper, ref command))
                {
                    return new UnauthorizedResult();
                }

                byte[] fileContent = await (mediaRepository?.GetAsync(docId, command)).ConfigureAwait(false);

                if (fileContent != null)
                {
                    return new FileContentResult(fileContent, "image/jpeg");
                }
                else
                {
                    functionRepository?.Logger.LogInformation("The requested Application/ApplicationArea does not match the image metadata {application} - {applicationArea} " 
                        + "or the user {userPrincipalName} does not have read permission to the requested Application/Area in BEAS",
                        application, applicationArea, command.UserPrincipalName);
                    return new UnauthorizedResult();
                }
            }
            catch (Exception ex)
            {   
                functionRepository?.Logger.LogError(ex, "Error getting media for doc {docId}", docId);
                return new InternalServerErrorResult();
            }
        }

        private static bool GetValidatedImage(HttpRequest req, ref MediaMetadata metadata)
        {
            IFormFile file = req.Form.Files.AsEnumerable().FirstOrDefault();
            var mimeType = file.ContentType;
            string extension = Path.GetExtension(file.FileName);

            metadata = new MediaMetadata { File = file, MimeType = mimeType, FileExtension = extension };

            // Basic validation on mime types and file extension
            return (Constants.ValidMimeTypes.Any(m => m.Equals(mimeType, StringComparison.InvariantCultureIgnoreCase))
                    && (Constants.ValidFilenameExtensions.Any(e => e.Equals(extension, StringComparison.InvariantCultureIgnoreCase))));
                
        }

        private static bool AuthenticateRequest(HttpRequest req, 
                                                            IFunctionRepository functionRepository, 
                                                            IAuthenticationHelper authenticationHelper, 
                                                            ref UserRoleCommand command)
        {
            var userName = functionRepository?.BearerTokenValidator.ExtractUserDetailsFromJWT(req)?.UniqueName;
            if (string.IsNullOrWhiteSpace(userName))
            {
                functionRepository?.Logger.LogInformation("A username was not specified in the calling token.");
                return false;
            }

            command.UserPrincipalName = userName;
            var accessToken = (authenticationHelper?.GetAccessTokenAsync()).Result;
            var isAccessValid = (authenticationHelper?.UserHasAccessAsync(accessToken, command)).Result;

            if (!isAccessValid)
            {
                functionRepository?.Logger.LogInformation("The user ({userName}) does not have BEAS permissions to access {ApplicationName} - {ApplicationAreaName} - {RoleName}",
                    userName, command.ApplicationName, command.ApplicationAreaName, command.RoleName);

                return false;
            }

            return true;
        }
        
    }
}
