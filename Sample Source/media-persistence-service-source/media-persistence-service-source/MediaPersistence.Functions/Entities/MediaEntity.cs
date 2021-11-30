using MediaPersistence.Functions.Commands;
using System.IO;

namespace MediaPersistence.Functions
{
    public class ImageGetData
    {
        public Stream Image { get; set; }
        public UserRoleCommand Metadata { get; set; }
    }
}