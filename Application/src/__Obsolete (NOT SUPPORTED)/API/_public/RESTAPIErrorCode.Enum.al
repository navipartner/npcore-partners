enum 6059797 "NPR REST API Error Code"
{
    Extensible = true;
    ObsoleteState = Pending;
    ObsoleteTag = '2024-10-13';
    ObsoleteReason = 'Removed REST from object name';

    value(0; generic_error)
    {
        Caption = 'Unspecified error occurred.', Locked = true;
    }

    value(10; unsupported_http_method)
    {
        Caption = 'The http method is not supported for this endpoint.', Locked = true;
    }

    value(20; resource_not_found)
    {
        Caption = 'The selected resource does not exist.', Locked = true;
    }
}