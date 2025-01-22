report 6060124 "NPR TM Ticket Batch Resp."
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/TM Ticket Batch Response.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Ticket Batch Response';
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(ReservationRequest; "NPR TM Ticket Reservation Req.")
        {
            column(ExternalOrderNo; ReservationRequest."External Order No.")
            {
            }
            column(Token; OrderUrl)
            {
            }
            column(ItemNo; ReservationRequest."External Item Code")
            {
            }
            column(Quantity; ReservationRequest.Quantity)
            {
            }
            column(EntryNo; ReservationRequest."Entry No.")
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = FIELD("Item No.");
                column(ItemDescription; Item.Description)
                {
                }
            }
            dataitem(TicketBom; "NPR TM Ticket Admission BOM")
            {
                DataItemLink = "Item No." = FIELD("Item No.");
                column(AdmissionCode; TicketBom."Admission Code")
                {
                }
                column(AdmissionDescription; TicketBom."Admission Description")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if (TicketDesignTemplateId <> '') or (TicketBom.Default and (TicketBom.NPDesignerTemplateId <> '')) then
                        TicketDesignTemplateId := TicketBom.NPDesignerTemplateId;
                end;

                trigger OnPreDataItem()
                begin
                    TicketDesignTemplateId := '';
                end;
            }
            dataitem(Ticket; "NPR TM Ticket")
            {
                DataItemLink = "Ticket Reservation Entry No." = FIELD("Entry No.");
                column(TicketNo; Ticket."External Ticket No.")
                {
                }
                column(ValidFromDate; Ticket."Valid From Date")
                {
                }
                column(ValidUntilDate; Ticket."Valid To Date")
                {
                }
                column(TicketURL; TicketURL)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if (ReservationRequest."DIY Print Order Requested") then
                        TicketURL := StrSubstNo(Pct1Lbl, TicketSetup."Print Server Ticket URL", Ticket."External Ticket No.");

                    if ((NpDesignTicketURL <> '') and (TicketDesignTemplateId <> '')) then
                        TicketURL := StrSubstNo(NpDesignTicketURL, Format(Ticket.SystemId, 0, 4).ToLower(), TicketDesignTemplateId);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                OrderUrl := ReservationRequest."Session Token ID";
                if (ReservationRequest."DIY Print Order Requested") then
                    OrderUrl := StrSubstNo(Pct1Lbl, TicketSetup."Print Server Order URL", ReservationRequest."Session Token ID");

                if ((NpDesignOrderURL <> '') and (TicketDesignTemplateId <> '')) then
                    OrderUrl := StrSubstNo(NpDesignOrderURL, ReservationRequest."Session Token ID", TicketDesignTemplateId);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }
    labels
    {
        YourRef = 'Your Reference:';
        OurRef = 'Our Reference:';
        Admission = 'Admission';
        AdmDesc = 'Description';
        TicketNumber = 'Ticket No';
        ValidFrom = 'Valid From';
        ValidUntil = 'Valid Until';
        ItemNumber = 'Item No.';
        ItemDesc = 'Item Description';
        Qty = 'Quantity';

    }

    trigger OnPreReport()
    begin
        if (TicketSetup.Get()) then;
        if (NpDesign.Get()) then begin
            NpDesignTicketURL := NpDesign.PublicTicketURL;
            NpDesignOrderURL := NpDesign.PublicOrderURL;
        end;
    end;

    var
        TicketSetup: Record "NPR TM Ticket Setup";
        NpDesign: Record "NPR NpDesignerSetup";
        TicketURL: Text;
        OrderUrl: Text;
        Pct1Lbl: Label '%1%2', locked = true;
        NpDesignTicketURL: Text;
        NpDesignOrderURL: Text;
        TicketDesignTemplateId: Text;

}

