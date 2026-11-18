# Single source of truth for the Meridian Steel lab build.
# Edit these values to match your environment before running any script.
@{
    DomainDN   = 'DC=lab,DC=local'
    RootOU     = 'Meridian'

    # UPN suffix for new users. For cloud sign-in this should be a routable,
    # verified domain in your Entra tenant (lab.local syncs as *.onmicrosoft.com).
    UpnSuffix  = 'lab.local'

    # Dedicated data drive (the second virtual disk on the DC)
    ShareRoot  = 'E:\MeridianShares'
    ShareName  = 'MeridianShares'

    # Rights for the manager tier. 'FullControl' matches the current design;
    # 'Modify' is the hardened option (see README section 10).
    ManagerRights = 'FullControl'

    Departments = @(
        @{ Name = 'Executive';                       Code = 'Executive'   }
        @{ Name = 'Finance / Accounting';            Code = 'Finance'     }
        @{ Name = 'HR';                              Code = 'HR'          }
        @{ Name = 'Project Management / Estimating'; Code = 'ProjectMgmt' }
        @{ Name = 'Engineering / Drafting';          Code = 'Engineering' }
        @{ Name = 'Shop / Fabrication';              Code = 'Shop'        }
        @{ Name = 'Field / Site Supervisors';        Code = 'Field'       }
        @{ Name = 'IT / Admin';                      Code = 'IT'          }
        @{ Name = 'Sales / Business Development';    Code = 'Sales'       }
    )
}
