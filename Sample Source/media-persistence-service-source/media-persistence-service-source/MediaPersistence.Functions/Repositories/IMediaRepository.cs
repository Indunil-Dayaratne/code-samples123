using MediaPersistence.Functions.Commands;
using MediaPersistence.Functions.Entities;
using System;
using System.Collections.Generic;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace MediaPersistence.Functions.Repositories
{
    public interface IMediaRepository
    {
        [Obsolete("This method is obsolete. Use GetAsync(docId, command), instead.", false)]
        Task<byte[]> GetAsync(string docResourceId, string attachmentResourceId, string docId, UserRoleCommand command);
        Task<byte[]> GetAsync(string docId, UserRoleCommand command);
        Task<string> SaveAsync(MediaMetadata input, UserRoleCommand command);
    }
}
