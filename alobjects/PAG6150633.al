page 6150633 "NPRE Flow Status"
{
    // NPR5.34/NPKNAV/20170801 CASE 283328 Transport NPR5.34 - 1 August 2017
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category

    Caption = 'Flow Status';
    PageType = List;
    SourceTable = "NPRE Flow Status";
    SourceTableView = SORTING("Status Object","Flow Order");
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
                field(PrintCategories;AssignedPrintCategoriesAsFilterString())
                {
                    Caption = 'Print Categories';
                    Editable = false;
                    Visible = ShowPrintCategories;

                    trigger OnDrillDown()
                    var
                        FlowStatusPrCategory: Record "NPRE Flow Status Pr.Category";
                    begin
                        //-NPR5.53 [360258]
                        TestField("Status Object","Status Object"::WaiterPadLineMealFlow);
                        TestField(Code);
                        FlowStatusPrCategory.SetRange("Flow Status Object","Status Object");
                        FlowStatusPrCategory.SetRange("Flow Status Code",Code);
                        PAGE.Run(0,FlowStatusPrCategory);
                        //+NPR5.53 [360258]
                    end;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(ActionGroup6014407)
            {
                action(PrintCategories)
                {
                    Caption = 'Print Categories';
                    Image = CoupledOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPRE Flow Status Pr.Categories";
                    RunPageLink = "Flow Status Object"=FIELD("Status Object"),
                                  "Flow Status Code"=FIELD(Code);
                    Visible = ShowPrintCategories;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ShowPrintCategories := "Status Object" = "Status Object"::WaiterPadLineMealFlow;  //NPR5.53 [360258]
    end;

    trigger OnOpenPage()
    begin
        if CurrPage.LookupMode then begin
          StatusObjectVisible := false;
        end else begin
          StatusObjectVisible := true;
        end;
        ShowPrintCategories := GetFilter("Status Object") = Format("Status Object"::WaiterPadLineMealFlow);  //NPR5.53 [360258]
    end;

    var
        ShowPrintCategories: Boolean;
        StatusObjectVisible: Boolean;
}

