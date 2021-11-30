using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;

namespace MediaPersistence.Functions.Entities
{
    public class MediaMetadata
    {
        public IFormFile File { get; set; }
        public string MimeType { get; set; }
        public string FileExtension { get; set; }
    }
}
