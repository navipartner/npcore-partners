page 6059985 "Retail Document Activities"
{
    // NPR4.14/RMT/20150826 CASE 216519 Added column "Number of Open Orders" and "Number of Posted Orders"
    //                                    toggle showing the queues based on the "Retail Setup"
    // NPR4.18/BHR/201151611 CASE 227343 Set Correct Caption

    Caption = 'Retail Document Activities';
    PageType = CardPart;
    SourceTable = "Retail Document Cue";

    layout
    {
        area(content)
        {
            cuegroup("Open Documents")
            {
                Caption = 'Open Documents';
                field("Selection Contracts Open";"Selection Contracts Open")
                {
                    DrillDownPageID = "Retail Document List";
                }
                field("Customizations Open";"Customizations Open")
                {
                    DrillDownPageID = "Retail Document List";
                }
                field("Retail Orders Open";"Retail Orders Open")
                {
                    DrillDownPageID = "Retail Document List";
                    Visible = NOT UseStandardOrderDocument;
                }
                field("Number of Open Orders";"Number of Open Orders")
                {
                    Visible = UseStandardOrderDocument;
                }

                actions
                {
                    action("New Selection Contract")
                    {
                        Caption = 'New Selection Contract';
                        RunObject = Page "Retail Document Header";
                        RunPageMode = Create;
                        RunPageView = SORTING("Document Type","No.")
                                      WHERE("Document Type"=CONST("Selection Contract"));
                    }
                    action("New Customization")
                    {
                        Caption = 'New Customization';
                        RunObject = Page "Retail Document Header";
                        RunPageMode = Create;
                        RunPageView = SORTING("Document Type","No.")
                                      WHERE("Document Type"=CONST("Selection Contract"));
                    }
                    action("New Retail Order")
                    {
                        Caption = 'New Retail Order';
                        RunObject = Page "Retail Document Header";
                        RunPageMode = Create;
                        RunPageView = SORTING("Document Type","No.")
                                      WHERE("Document Type"=CONST("Selection Contract"));
                    }
                }
            }
            cuegroup("Cashed Documents")
            {
                Caption = 'Cashed Documents';
                field("Selection Contracts Cashed";"Selection Contracts Cashed")
                {
                    DrillDownPageID = "Retail Document List";
                }
                field("Customizations Cashed";"Customizations Cashed")
                {
                    DrillDownPageID = "Retail Document List";
                }
                field("Retail Orders Cashed";"Retail Orders Cashed")
                {
                    DrillDownPageID = "Retail Document List";
                    Visible = NOT UseStandardOrderDocument;
                }
                field("Number of Posted Orders";"Number of Posted Orders")
                {
                    Visible = UseStandardOrderDocument;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    var
        RetailSetup: Record "Retail Setup";
    begin
        //-NPR4.14
        RetailSetup.Get;
        UseStandardOrderDocument := RetailSetup."Use Standard Order Document";
        //+NPR4.14
    end;

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;
    end;

    var
        UseStandardOrderDocument: Boolean;
}

