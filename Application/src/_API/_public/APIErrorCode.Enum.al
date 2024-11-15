enum 6059810 "NPR API Error Code"
{
    Extensible = true;

    value(0; generic_error)
    {
        Caption = 'An error occurred. See HTTP status code.', Locked = true;
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