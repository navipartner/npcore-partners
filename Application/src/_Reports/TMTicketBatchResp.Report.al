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
            column(Token; ReservationRequest."Session Token ID")
            {
            }
            column(OrderUrl; OrderUrl)
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
                var
                    Manifest: Codeunit "NPR NPDesignerManifestFacade";
                    ManifestId: Guid;
                begin
                    if (ReservationRequest."DIY Print Order Requested") then
                        TicketURL := StrSubstNo(Pct1Lbl, TicketSetup."Print Server Ticket URL", Ticket."External Ticket No.");

                    if ((NpDesignTicketURL <> '') and (TicketDesignTemplateId <> '')) then
                        TicketURL := StrSubstNo(NpDesignTicketURL, Format(Ticket.SystemId, 0, 4).ToLower(), TicketDesignTemplateId);

                    if (_UseManifest) then begin
                        ManifestId := Manifest.CreateManifest(TicketDesignTemplateId);
                        Manifest.AddAssetToManifest(ManifestId, Database::"NPR TM Ticket", Ticket.SystemId, Ticket."External Ticket No.", TicketDesignTemplateId);
                        Manifest.GetManifestUrl(ManifestId, TicketURL);
                        _TicketsToManifest.Add(Ticket.SystemId, Ticket."External Ticket No.");
                    end;

                end;
            }
            trigger OnAfterGetRecord()
            var
                OrderTicketBom: Record "NPR TM Ticket Admission BOM";
                Manifest: Codeunit "NPR NPDesignerManifestFacade";
            begin
                OrderUrl := ReservationRequest."Session Token ID";
                if (ReservationRequest."DIY Print Order Requested") then
                    OrderUrl := StrSubstNo(Pct1Lbl, TicketSetup."Print Server Order URL", ReservationRequest."Session Token ID");

                if ((NpDesignOrderURL <> '') and (TicketDesignTemplateId <> '')) then
                    OrderUrl := StrSubstNo(NpDesignOrderURL, ReservationRequest."Session Token ID", TicketDesignTemplateId);

                if (_UseManifest) then begin
                    OrderTicketBom.SetCurrentKey("Item No.");
                    OrderTicketBom.SetFilter("Item No.", '=%1', ReservationRequest."Item No.");
                    OrderTicketBom.SetFilter(Default, '=%1', true);
                    OrderTicketBom.SetFilter("NPDesignerTemplateId", '<>%1', '');
                    if (OrderTicketBom.FindFirst()) then begin
                        _OrderManifestTemplateId := OrderTicketBom.NPDesignerTemplateId;
                        _OrderManifestId := Manifest.CreateManifest(_OrderManifestTemplateId);
                        Manifest.GetManifestUrl(_OrderManifestId, OrderUrl);
                    end;
                end;
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
            _UseManifest := NpDesign.EnableManifest;
            if (not _UseManifest) then begin
                NpDesignTicketURL := NpDesign.PublicTicketURL;
                NpDesignOrderURL := NpDesign.PublicOrderURL;
            end;
        end;
    end;

    trigger OnPostReport()
    var
        Manifest: Codeunit "NPR NPDesignerManifestFacade";
        FailedTickets: List of [Guid];
    begin
        if (_UseManifest) then begin
            if (_TicketsToManifest.Count() = 0) then
                exit;

            if (not IsNullGuid(_OrderManifestId)) then
                Manifest.AddAssetToManifest(_OrderManifestId, Database::"NPR TM Ticket", _TicketsToManifest, _OrderManifestTemplateId, FailedTickets);
        end;
    end;

    var
        TicketSetup: Record "NPR TM Ticket Setup";
        NpDesign: Record "NPR NpDesignerSetup";
        TicketURL: Text[250];
        OrderUrl: Text[250];
        Pct1Lbl: Label '%1%2', locked = true;
        NpDesignTicketURL: Text;
        NpDesignOrderURL: Text;
        _UseManifest: Boolean;
        TicketDesignTemplateId: Text[40];
        _TicketsToManifest: Dictionary of [Guid, Text[100]];
        _OrderManifestId: Guid;
        _OrderManifestTemplateId: Text[40];


}

