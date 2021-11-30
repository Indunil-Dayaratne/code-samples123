using MediaPersistence.Functions.Helpers;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace MediaPersistence.UnitTests.Mock
{
    public class MockBlobStorageHelper : IBlobStorageHelper
    {
        public Task<byte[]> GetItemAsync(Uri blobUri)
        {
            return Task.FromResult(Encoding.ASCII.GetBytes("ABC"));
        }

        public Task<string> SaveAsync(string blobReference, Stream stream)
        {
            return Task.FromResult("https://medpersfuncstoruksdev.blob.core.windows.net/medperscontainuksdev/unit-test/D6Ntjj2W4AAyOed.jpg");
        }
    }
}
