namespace EntrySheet.Api.Function.Models
{
    /// <summary>
    /// This interface allows a generic function to loop through any list to find a policy ref
    /// </summary>
    public interface IPolicyRefModel
    {
        string PolicyRef { get; set; }
    }
}
