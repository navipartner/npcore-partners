page 6014541 "NPR Report Selection: Contract"
{
    // NPR5.26/TS/20160809 CASE 248289 Changed OptionString Values
    // NPR5.30/MHA /20170201  CASE 264918 Object renamed from Report Selection - Photo to Report Selection - Contract and Np Photo removed
    // NPR5.30/BHR /20170203  CASE 262923  Fields 8 to 11 added to page

    Caption = 'Report Type - Contract';
    DelayedInsert = true;
    PageType = Card;
    SourceTable = "NPR Report Selection: Contract";
    UsageCategory = Administration;

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
                    //-NPR5.30 [264918]
                    //SætBrugsFilter;
                    SetReportTypeFilter();
                    //+NPR5.30 [264918]
                    CurrPage.Update(true);
                end;
            }
            repeater(Control6150615)
            {
                ShowCaption = false;
                field(Sequence; Sequence)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sequence field';
                }
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Report ID field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("XML Port ID"; "XML Port ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the XML Port ID field';
                }
                field("XML Port Name"; "XML Port Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the XML Port Name field';
                }
                field("Report Name"; "Report Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Report Name field';
                }
                field("Codeunit ID"; "Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Codeunit ID field';
                }
                field("Codeunit Name"; "Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Codeunit Name field';
                }
                field("Print Template"; "Print Template")
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
        //-NPR5.30 [264918]
        ReportType := "Report Type"::"Insurance Offer";
        SetReportTypeFilter();
        //+NPR5.30 [264918]
    end;

    var
        ReportType: Option ,"Insurance Offer",Police,"Guarantee Certificate",,,"Reparation Reminder","Shipment note","Customer receipt","Repair warranty","Repair finished","Repair offer","Rental contract","Purchase contract",CustLetter,"Contract financing",Signs,Status,Quote;

    local procedure SetReportTypeFilter()
    begin
        FilterGroup(2);
        SetRange("Report Type", ReportType);
        FilterGroup(0);
        CurrPage.Update(false);
    end;
}

