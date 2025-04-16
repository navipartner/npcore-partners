
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
permissionset 6014416 "NPR All Webhooks"
{
    // Add ALL our webhook codeunits to this permissionset so that they can all be excluded by default from our API permissionsets

    Assignable = false;
    Permissions =
        codeunit "NPR POS Webhooks" = X,
        codeunit "NPR MM MembershipWebHooks" = X;
}
#endif