namespace BritServices.BearerTokenHelper.Configuration
{
    public interface ISettings
    {
        string Audience { get; set; }
        string OpenIdConfigurationEndPoint { get; set; }
        string ValidIssuers { get; set; }
    }
}