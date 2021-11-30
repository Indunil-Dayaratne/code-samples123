using System.Web.Mvc;
using static BEAS.Web.FilterConfig;

namespace BEAS.Web.Controllers
{
    public class UsersController : Controller
    { 
        [AllowCrossSiteJson]
        public ActionResult Index()
        {
            return PartialView();
        }

        [AllowCrossSiteJson]
        public ActionResult UserInfo()
        {
            return PartialView("UserInfo");
        }

        [AllowCrossSiteJson]
        public ActionResult UserRoleInfo()
        {
            return PartialView("UserRoleInfo");
        }

    }
}