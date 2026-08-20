pageextension 6014469 "NPR Entra App Time Zone Card" extends "AAD Application Card"
{
    layout
    {
        addafter("Contact Information")
        {
            field("NPR Time Zone Id"; Rec."NPR Time Zone Id")
            {
                ToolTip = 'Specifies the time zone that web service requests authenticated by this Microsoft Entra application use when they write local date and time fields. Leave blank to use the session time zone.';
                ApplicationArea = NPRRetail;

                trigger OnAssistEdit()
                var
                    TimeZoneSelection: Codeunit "Time Zone Selection";
                    TimeZoneId: Text[180];
                begin
                    TimeZoneId := Rec."NPR Time Zone Id";
                    if TimeZoneSelection.LookupTimeZone(TimeZoneId) then
                        Rec.Validate("NPR Time Zone Id", TimeZoneId);
                end;
            }
        }
    }
}
