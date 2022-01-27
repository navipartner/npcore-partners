report 6014410 "NPR Config. Template Line Fix"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    ApplicationArea = All;
    Caption = 'Config. Template Line Fix';
    UsageCategory = Administration;
    ProcessingOnly = true;
    dataset
    {
        dataitem(ConfigTemplateLine; "Config. Template Line")
        {
            RequestFilterFields = "Data Template Code";
            DataItemTableView = sorting("Data Template Code", "Line No.") where("Field Name" = const(''));

            trigger OnAfterGetRecord()
            var
                Fields: Record Field;
            begin
                if Fields.Get("Table ID", "Field ID") then begin
                    "Field Name" := Fields.FieldName;
                    Modify();
                end;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }

    }


}
