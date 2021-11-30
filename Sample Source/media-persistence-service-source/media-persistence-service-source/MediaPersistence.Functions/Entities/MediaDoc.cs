using Newtonsoft.Json;

namespace MediaPersistence.Functions.Entities
{
    public class MediaDoc
    {
        [JsonProperty(PropertyName = "id")]
        public string Id { get; set; }

        [JsonProperty(PropertyName = "application")]
        public string Application { get; set; }

        [JsonProperty(PropertyName = "application_Area")]
        public string ApplicationArea { get; set; }

        [JsonProperty(PropertyName = "user")]
        public string User { get; set; }

        [JsonProperty(PropertyName = "data_classification")]
        public string DataClassification { get; set; }

        [JsonProperty(PropertyName = "file_url")]
        public string FileUrl { get; set; }
    }
}
