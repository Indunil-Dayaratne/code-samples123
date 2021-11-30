using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class OrganisationModel
    { 
        public string PartyName { get; set; }
        protected bool Equals(OrganisationModel other)
        {
            return string.Equals(PartyName, other.PartyName);
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(null, obj)) return false;
            if (ReferenceEquals(this, obj)) return true;
            if (obj.GetType() != this.GetType()) return false;
            return Equals((OrganisationModel) obj);
        }

        public override int GetHashCode()
        {
            return (PartyName != null ? PartyName.GetHashCode() : 0);
        }
    }
}
