page 6014541 "NPR Report Selection: Contract"
{
    Caption = 'Report Type - Contract';
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "NPR Report Selection: Contract";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            field(ReportType; ReportType)
            {
                ApplicationArea = All;
                Caption = 'Report Type';
                ToolTip = 'Specifies the value of the Report Type field';

                trigger OnValidate()
                begin
                    SetReportTypeFilter();
                    CurrPage.Update(true);
                end;
            }
            repeater(Control6150615)
            {
                ShowCaption = false;
                field(Sequence; Rec.Sequence)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sequence field';
                }
                field("Report ID"; Rec."Report ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Report ID field';
                }
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("XML Port ID"; Rec."XML Port ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the XML Port ID field';
                }
                field("XML Port Name"; Rec."XML Port Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the XML Port Name field';
                }
                field("Report Name"; Rec."Report Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Report Name field';
                }
                field("Codeunit ID"; Rec."Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Codeunit ID field';
                }
                field("Codeunit Name"; Rec."Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Codeunit Name field';
                }
                field("Print Template"; Rec."Print Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Template field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(List)
            {
                Caption = 'List';
                Image = List;
                RunObject = Page "NPR Retail Report Select. List";
                ApplicationArea = All;
                ToolTip = 'Executes the List action';
            }
        }
    }

    trigger OnOpenPage()
    begin
        ReportType := Rec."Report Type"::"Insurance Offer";
        SetReportTypeFilter();
    end;

    var
        ReportType: Option ,"Insurance Offer",Police,"Guarantee Certificate",,,"Reparation Reminder","Shipment note","Customer receipt","Repair warranty","Repair finished","Repair offer","Rental contract","Purchase contract",CustLetter,"Contract financing",Signs,Status,Quote;

    local procedure SetReportTypeFilter()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Report Type", ReportType);
        Rec.FilterGroup(0);
        CurrPage.Update(false);
    end;
}

