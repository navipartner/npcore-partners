page 6150633 "NPRE Flow Status"
{
    // NPR5.34/NPKNAV/20170801  CASE 283328 Transport NPR5.34 - 1 August 2017
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant

    Caption = 'Flow Status';
    PageType = List;
    SourceTable = "NPRE Flow Status";
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
                field("Status Object";"Status Object")
                {
                    Editable = StatusObjectVisible;
                    Enabled = StatusObjectVisible;
                    Visible = StatusObjectVisible;
                }
                field(Description;Description)
                {
                }
                field("Flow Order";"Flow Order")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if CurrPage.LookupMode then begin
          StatusObjectVisible := false;
        end else begin
          StatusObjectVisible := true;
        end;
    end;

    var
        StatusObjectVisible: Boolean;
}

