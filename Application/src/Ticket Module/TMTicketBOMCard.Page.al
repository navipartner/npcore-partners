page 6059886 "NPR TM Ticket BOM Card"
{
    Extensible = False;
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR TM Ticket Admission BOM";
    Caption = 'Ticket Bill-of-Material';
    PromotedActionCategories = 'New,Process,Report,Create Tickets,Navigate';
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';

    layout
    {
        area(Content)
        {
            group(Setup)
            {
                Caption = 'Ticket Admission Setup';
                group(Ticket)
                {
                    Caption = '';
                    field("Item No."; Rec."Item No.")
                    {
                        ToolTip = 'Specifies the identification number of an item created in the ERP system that is used in the POS for selling a specific ticket. ';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Variant Code"; Rec."Variant Code")
                    {
                        ToolTip = 'Specifies the code that is added to the value in the Item No. column to determine the ticket type (e.g., tickets for children/adults/seniors). Microsoft only supports one dimension of variants.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Admission Code"; Rec."Admission Code")
                    {
                        ToolTip = 'Specifies the type of admission that the ticket can be used for. Tickets offer different levels of clearance, and they may allow access to multiple sites (e.g., dungeon and treasury tours in a castle).';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies useful information about the ticket, that can be included on the printed ticket.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Admission Description"; Rec."Admission Description")
                {
                    ToolTip = 'Specifies useful information about the admission that can be included on a printed ticket.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Default; Rec.Default)
                {
                    ToolTip = 'Specifies the default admission when multiple admissions are created for the ticket.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(DeferRevenue; Rec.DeferRevenue)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies if the revenue should be deferred until this admission is admitted or ticket has expired.';
                }

            }
            group(Policies)
            {
                Caption = 'Policies and Constraints';

                field("Activation Method"; Rec."Activation Method")
                {
                    ToolTip = 'Determines when the ticket is recorded as admitted. The activation can, for example, occur automatically after sales.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket Schedule Selection"; Rec."Ticket Schedule Selection")
                {
                    ToolTip = 'Specifies the default POS schedule selection behavior, intended to provide a smart assist for the walk-up ticket sales process.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                group(Admission)
                {
                    Caption = 'Admission';
                    field("Admission Entry Validation"; Rec."Admission Entry Validation")
                    {
                        ToolTip = 'Determines how many times the ticket can be validated when admitting entry.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Max No. Of Entries"; Rec."Max No. Of Entries")
                    {
                        ToolTip = 'Determines the maximum number of entries to an admission that can be made before the ticket becomes invalid.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Allow Rescan Within (Sec.)"; Rec."Allow Rescan Within (Sec.)")
                    {
                        ToolTip = 'Specifies the number of seconds after scan during which the ticket can be rescanned even though ticket only allows a single admission. If no value is stated, the ticket can’t be rescanned (assuming single entry is allowed). This option is useful for speed gates, in case a person fails to enter and immediately retries entry.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Admission Dependency Code"; Rec."Admission Dependency Code")
                    {
                        ToolTip = 'Determines if some location / events are exclusive of each other, or if there are locations / events managed by the ticket that needs to be visited in a specific order.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                }

                group(Reschedule)
                {
                    Caption = 'Reschedule Policy';
                    field("Reschedule Policy"; Rec."Reschedule Policy")
                    {
                        ToolTip = 'Specifies whether it’s possible to change the ticket reservation time.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Reschedule Cut-Off (Hours)"; Rec."Reschedule Cut-Off (Hours)")
                    {
                        ToolTip = 'Specifies after how many hours it’s possible to reschedule if Cut-Off (Hours) is selected in the Reschedule Policy column.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                }
                group(Revoke)
                {
                    Caption = 'Revoke Policy';
                    field("Revoke Policy"; Rec."Revoke Policy")
                    {
                        ToolTip = 'Specifies whether it’s possible to receive a refund for a ticket (e.g., if it’s unused).';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Refund Price %"; Rec."Refund Price %")
                    {
                        ToolTip = 'Specifies the percentage of the ticket price that is refunded to customers (if refunds are performed).';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                }
                group(Capacity)
                {
                    Caption = 'Capacity';
                    field("Percentage of Adm. Capacity"; Rec."Percentage of Adm. Capacity")
                    {
                        ToolTip = 'Determines a percentage of maximum admission capacity for the provided Item No.. This is a useful option when there are several types of tickets sold for the same admission.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("POS Sale May Exceed Capacity"; Rec."POS Sale May Exceed Capacity")
                    {
                        ToolTip = 'Specifies whether the capacity may be exceed when ticket is sold in POS.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                }

                group(Sales)
                {
                    Caption = 'Sales';
                    field("Admission Inclusion"; Rec."Admission Inclusion")
                    {
                        ToolTip = 'Specifies the value of the Admission Inclusion field.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Admission Unit Price"; Rec."Admission Unit Price")
                    {
                        ToolTip = 'Specifies the value of the Admission Unit Price field.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Duration Formula"; Rec."Duration Formula")
                    {
                        ToolTip = 'Determines the period during which the ticket is valid.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field(DurationGroupCode; Rec.DurationGroupCode)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Duration Group Code';
                        ToolTip = 'Determines whether the admission is limited by duration rather than the scheduled end time.';
                    }
                    field("Enforce Schedule Sales Limits"; Rec."Enforce Schedule Sales Limits")
                    {
                        ToolTip = 'Determines if the values in the Sales From Date/Sales Until Date columns are enforced.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Sales From Date"; Rec."Sales From Date")
                    {
                        ToolTip = 'Specifies date from which the ticket can be purchased.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Sales Until Date"; Rec."Sales Until Date")
                    {
                        ToolTip = 'Specifies the date until which the ticket can be purchased.';
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                }

            }
            group(Notification)
            {
                Caption = 'Notification';
                field("Notification Profile Code"; Rec."Notification Profile Code")
                {
                    ToolTip = 'Specifies which events will trigger notifications to be sent to the ticket holder. This option is useful for CRM purposes.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
            }
            group(eTicket)
            {
                Caption = 'e-Ticket';

                field("eTicket Type Code"; Rec."eTicket Type Code")
                {
                    ToolTip = 'Specifies the ticket design options used for displaying the ticket in the Wallet.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Publish As eTicket"; Rec."Publish As eTicket")
                {
                    ToolTip = 'Specifies that this ticket should be published using the Apple Wallet technology.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Publish Ticket URL"; Rec."Publish Ticket URL")
                {
                    ToolTip = 'Specifies the URL to the server on which you can share the ticket with customers.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
            }
            group(Misc)
            {
                Caption = 'Miscellaneous';

                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Revisit Condition (Statistics)"; Rec."Revisit Condition (Statistics)")
                {
                    ToolTip = 'Specifies how to define a unique visitor when a ticket is used more than once.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Prefered Sales Display Method"; Rec."Prefered Sales Display Method")
                {
                    Caption = 'Preferred Sales Display Method';
                    ToolTip = 'Specifies the value of the Preferred Sales Display Method field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket Base Calendar Code"; Rec."Ticket Base Calendar Code")
                {
                    ToolTip = 'Specifies the code of a base calendar. The calendar defines exceptions to the general schedules and has the possibility to prevent sales for specific dates or holidays.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket Customized Calendar"; _CalendarManager.CustomizedChangesExist(Rec))
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Customized Calendar';
                    Editable = false;
                    ToolTip = 'If a base calendar is added, you can select calendar variations in this column that applies to this ticket specifically.';

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord();
                        Rec.TestField("Ticket Base Calendar Code");
                        _CalendarManager.ShowCustomizedCalendar(Rec);
                    end;
                }

                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            Action(NavigateIssuedTickets)
            {
                ToolTip = 'Navigate to Issued Tickets';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Issued Tickets';
                Image = Navigate;
                RunObject = Page "NPR TM Ticket List";
                RunPageLink = "Item No." = field("Item No.");
            }
            Action(NavigateDefaultAdmission)
            {
                ToolTip = 'Navigate to Default Admission per POS Unit';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Default Admission per POS Unit';
                Image = Default;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "NPR TM POS Default Admission";
                RunPageLink = "Item No." = field("Item No."), "Variant Code" = field("Variant Code");
            }
            Action(NavigateTicketType)
            {
                ToolTip = 'Navigate to Ticket Type';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Types';
                Image = Category;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "NPR TM Ticket Type";
            }
            Action(NavigateItems)
            {
                ToolTip = 'Navigate to Item Card.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Item';
                Image = ItemLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "Item Card";
                RunPageLink = "No." = field("Item No.");
            }
        }

    }

    var
        _CalendarManager: Codeunit "Calendar Management";

}