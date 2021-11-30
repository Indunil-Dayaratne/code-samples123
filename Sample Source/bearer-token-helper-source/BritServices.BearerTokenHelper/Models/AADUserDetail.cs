namespace BritServices.BearerTokenHelper.Models
{
    public class AADUserDetail
    {
        public string FamilyName { get; set; }
        public string GivenName { get; set; }
        public string Name { get; set; }
        public string UniqueName { get; set; }
        public string UPN { get; set; }
        public string ObjectId { get; set; }
        public string Email { get; set; }
        public bool IsExternalUser { get; set; }

    }
}
