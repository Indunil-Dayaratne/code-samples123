namespace EntrySheet.WebApp
{
    public class Settings
    {
        public string RootUrl { get; set; }
        public string KeyVaultResourceId { get; set; }
        public string EnableBISubLimitForGroupClass { get; set; }
        public string LineStatuses { get; set; }
        public string PbqaPlacingBasisTypes { get; set; }
    }
    public class BeasOptions
    {
        public string BaseUrl { get; set; }
        public string ApplicationName { get; set; }
        public string ApplicationArea { get; set; }
        public string ApplicationRole { get; set; }
        public string ApplicationNameInternal { get; set; }
        public string ApplicationAreaInternal { get; set; }
        public string ApplicationRoleReadOnly { get; set; }
        public string ApplicationRoleWrite { get; set; }
    }

    public class EntrySheetApi
    {
        public string ClientId { get; set; }
        public string Scope { get; set; }
        public string BaseUrl { get; set; }
    }
    public class PbqaApi
    {
        public string ClientId { get; set; }
        public string Scope { get; set; }
        public string BaseUrl { get; set; }
    }

    public class IgnisApi
    {
        public string BaseUrl { get; set; }
        public string EnvironmentName { get; set; }
    }
}
