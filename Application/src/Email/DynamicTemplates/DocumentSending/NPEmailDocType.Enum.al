enum 6248731 "NPR NPEmailDocType" implements "NPR INPEmailDocType"
{
    Access = Internal;

    value(0; Undefined)
    {
        Caption = ' ', Locked = true;
        Implementation = "NPR INPEmailDocType" = "NPR NPEmailUndefDocType";
    }
    value(1; "Posted Sales Invoice")
    {
        Caption = 'Posted Sales Invoice';
        Implementation = "NPR INPEmailDocType" = "NPR NPEmailPostSIDocType";
    }
}
