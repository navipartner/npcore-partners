page 6150689 "NPRE Kitchen Requests"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

    Caption = 'Kitchen Request List';
    Editable = false;
    PageType = Worksheet;
    SourceTable = "NPRE Kitchen Request";
    SourceTableView = SORTING("Restaurant Code","Line Status",Priority,"Order ID","Created Date-Time");
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater("Order Lines")
            {
                Caption = 'Order Lines';
                IndentationColumn = 0;
                field("Request No.";"Request No.")
                {
                }
                field("Order ID";"Order ID")
                {
                }
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field(Description;Description)
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                }
                field("Serving Step";"Serving Step")
                {
                }
                field("Created Date-Time";"Created Date-Time")
                {
                }
                field("Serving Requested Date-Time";"Serving Requested Date-Time")
                {
                }
                field("Line Status";"Line Status")
                {
                }
                field("Production Status";"Production Status")
                {
                }
                field("No. of Kitchen Stations";"No. of Kitchen Stations")
                {
                }
                field("Restaurant Code";"Restaurant Code")
                {
                    Visible = false;
                }
                field("Source Document Type";"Source Document Type")
                {
                }
                field("Source Document No.";"Source Document No.")
                {
                }
                field("Source Document Line No.";"Source Document Line No.")
                {
                    Visible = false;
                }
            }
            part("Kitchen Stations";"NPRE Kitchen Requests Subpage")
            {
                Caption = 'Kitchen Stations';
                SubPageLink = "Request No."=FIELD("Request No."),
                              "Production Restaurant Code"=FIELD("Production Restaurant Filter"),
                              "Kitchen Station"=FIELD("Kitchen Station Filter");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Served")
            {
                Caption = 'Set Served';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    KitchenRequest: Record "NPRE Kitchen Request";
                begin
                    CurrPage.SetSelectionFilter(KitchenRequest);
                    KitchenOrderMgt.SetRequestLinesAsServed(KitchenRequest);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        KitchenOrderMgt: Codeunit "NPRE Kitchen Order Mgt.";
}

