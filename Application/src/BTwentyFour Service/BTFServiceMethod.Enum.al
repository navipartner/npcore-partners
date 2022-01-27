enum 6014408 "NPR BTF Service Method"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; "GET")
    {
        Caption = 'GET';
    }
    value(1; "POST")
    {
        Caption = 'POST';
    }
    value(2; "PUT")
    {
        Caption = 'PUT';
    }
    value(3; "PATCH")
    {
        Caption = 'PATCH';
    }
    value(4; "DELETE")
    {
        Caption = 'DELETE';
    }
}
