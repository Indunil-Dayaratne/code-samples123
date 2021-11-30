using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BEAS.AspNetCore.Client.Models;
using ConfigurationSecrets.Models;
using ESB.Models;
using ESB.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Options;

namespace ESB.Pages
{
    public class StatusModel : PageModel
    {
        public ESBInformation BusInformation { get; private set; }
        public string EnvironmentName { get; private set; }
        public KeyVaultCredentialSettings KeyVaultCredentialSettings { get; private set; }
        public BEASSettings BEASSettings { get; private set; }

        [Authorize("ESB-Admin")]
        public async Task OnGetAsync([FromServices] ISASGenerator sasGenerator, [FromServices] IHostingEnvironment evironment, [FromServices] IOptions<BEASSettings> bEASSettings, [FromServices] IConfiguration config)
        {
            BusInformation = await sasGenerator.GetBusInformationAsync();
            EnvironmentName = evironment.EnvironmentName;
            BEASSettings = bEASSettings.Value;
            SecretsSettings settings = config.GetSection("Secrets").Get<SecretsSettings>();
            KeyVaultCredentialSettings = settings.KeyVaultCredentials;
        }
    }
}