tableextension 6014412 "NPR Entra App Time Zone" extends "AAD Application"
{
    fields
    {
        field(6014402; "NPR Time Zone Id"; Text[180])
        {
            Caption = 'Time Zone';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the time zone that web service requests authenticated by this Microsoft Entra application use when they write local date and time fields. Leave blank to use the session time zone.';

            trigger OnValidate()
            var
                TimeZoneSelection: Codeunit "Time Zone Selection";
                TimeZoneId: Text[180];
            begin
                if "NPR Time Zone Id" = '' then
                    exit;

                TimeZoneId := "NPR Time Zone Id";
                TimeZoneSelection.ValidateTimeZone(TimeZoneId);
                "NPR Time Zone Id" := TimeZoneId;
            end;
        }
    }
}
