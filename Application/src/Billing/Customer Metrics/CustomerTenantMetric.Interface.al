/// <summary>
/// A date metric whose value is the same in every company of the environment, so only the company that claims a business date sends it.
/// </summary>
interface "NPR ICustomer Tenant Metric" extends "NPR ICustomer Date Metric"
{
    Access = Internal;
}
