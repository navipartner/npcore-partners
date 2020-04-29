page 6184483 "EFT Integration Types"
{
    // NPR5.30/BR  /20170113  CASE 263458 Object Created
    // NPR5.46/MMV /20180926 CASE 290734 EFT Framework refactored

    Caption = 'EFT Integration Types';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "EFT Integration Type";
    SourceTableTemporary = true;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Codeunit ID";"Codeunit ID")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        EFTInterface: Codeunit "EFT Interface";
    begin
        //-NPR5.46 [290734]
        if Rec.IsEmpty then begin
          EFTInterface.OnDiscoverIntegrations(Rec);
        end;
        //+NPR5.46 [290734]
    end;
}

