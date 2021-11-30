using MediaPersistence.Functions.Commands;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace MediaPersistence.Functions.Helpers.Interfaces
{
    public interface IAuthenticationHelper
    {
        Task<string> GetAccessTokenAsync();
        Task<string> GetMediaDBAccessTokenAsync();

        Task<bool> UserHasAccessAsync(string accessToken, UserRoleCommand command);

    }
}
