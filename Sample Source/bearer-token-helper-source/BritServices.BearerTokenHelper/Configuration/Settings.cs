namespace BritServices.BearerTokenHelper.Configuration
{
    public class Settings : ISettings
    {       
        public string OpenIdConfigurationEndPoint { get; set; }
        public string ValidIssuers { get; set; }
        public string Audience { get; set; }
    }
}
