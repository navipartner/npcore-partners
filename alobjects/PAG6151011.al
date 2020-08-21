page 6151011 "NpRv Voucher Modules"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher

    Caption = 'Retail Voucher Modules';
    PageType = List;
    SourceTable = "NpRv Voucher Module";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Event Codeunit ID"; "Event Codeunit ID")
                {
                    ApplicationArea = All;
                }
                field("Event Codeunit Name"; "Event Codeunit Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        NpRvModuleMgt: Codeunit "NpRv Module Mgt.";
    begin
        NpRvModuleMgt.OnInitVoucherModules(Rec);
    end;
}

