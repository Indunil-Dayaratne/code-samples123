using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using ESB.Models;
using ESB.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace ESB.Controllers
{
    [Produces("application/json")]
    public class SASController : Controller
    {
        private readonly ISASGenerator _sASGenerator;

        public SASController(ISASGenerator sASGenerator)
        {
            _sASGenerator = sASGenerator;
        }

        [Authorize("ESB-Read")]
        [HttpGet("BlobSASToken/{containerName}")]
        public async Task<TokenDetails> GetBlobContainerTokenAsync([FromRoute] string containerName)
        {
            TokenDetails tokenDetails = await _sASGenerator.GetBlobContainerSASTokenAsync(containerName);
            return tokenDetails;
        }

        [Authorize("ESB-Read")]
        [HttpGet("Container/{containerName}/LastUpdated")]
        public async Task<string> GetContainerLastUpdatedAsync([FromRoute] string containerName)
        {
            return await _sASGenerator.GetContainerLastUpdatedAsync(containerName);
        }

        [Authorize("ESB-Write")]
        [HttpPost("Container/{containerName}/LastUpdated")]
        public async Task SetContainerLastUpdatedAsync([FromRoute] string containerName, [FromBody] string lastUpdated)
        {
            await _sASGenerator.SetContainerLastUpdatedAsync(containerName, lastUpdated);
        }
    }
}