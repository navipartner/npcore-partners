page 6014541 "Report Selection - Contract"
{
    // NPR5.26/TS/20160809 CASE 248289 Changed OptionString Values
    // NPR5.30/MHA /20170201  CASE 264918 Object renamed from Report Selection - Photo to Report Selection - Contract and Np Photo removed
    // NPR5.30/BHR /20170203  CASE 262923  Fields 8 to 11 added to page

    Caption = 'Report Type - Contract';
    DelayedInsert = true;
    PageType = Card;
    SourceTable = "Report Selection - Contract";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            field(ReportType;ReportType)
            {
                Caption = 'Report Type';

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
                field(Sequence;Sequence)
                {
                }
                field("Report ID";"Report ID")
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("XML Port ID";"XML Port ID")
                {
                }
                field("XML Port Name";"XML Port Name")
                {
                }
                field("Report Name";"Report Name")
                {
                }
                field("Codeunit ID";"Codeunit ID")
                {
                }
                field("Codeunit Name";"Codeunit Name")
                {
                }
                field("Print Template";"Print Template")
                {
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
                RunObject = Page "Retail Report Selection List";
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
        SetRange( "Report Type", ReportType );
        FilterGroup(0);
        CurrPage.Update(false);
    end;
}

