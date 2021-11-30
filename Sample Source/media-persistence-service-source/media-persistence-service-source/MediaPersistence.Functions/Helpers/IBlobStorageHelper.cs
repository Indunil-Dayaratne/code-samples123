using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace MediaPersistence.Functions.Helpers
{
    public interface IBlobStorageHelper
    {
        Task<string> SaveAsync(string blobReference, Stream stream);
        Task<byte[]> GetItemAsync(Uri blobUri);
    }
}
