page 6151011 "NPR NpRv Voucher Modules"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher

    Caption = 'Retail Voucher Modules';
    PageType = List;
    SourceTable = "NPR NpRv Voucher Module";
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
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Event Codeunit ID"; "Event Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Codeunit ID field';
                }
                field("Event Codeunit Name"; "Event Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Codeunit Name field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
    begin
        NpRvModuleMgt.OnInitVoucherModules(Rec);
    end;
}

