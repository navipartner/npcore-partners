page 6150744 "Archive POS Sale"
{
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale

    Caption = 'Archive POS Sale';
    Editable = false;
    PageType = Document;
    SourceTable = "Archive Sale POS";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; "Register No.")
                {
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                }
                field(Date; Date)
                {
                }
                field("Start Time"; "Start Time")
                {
                }
                field("Customer No."; "Customer No.")
                {
                }
                field(Name; Name)
                {
                    Visible = false;
                }
                field("Customer Name"; "Customer Name")
                {
                }
                field("Location Code"; "Location Code")
                {
                }
                field(Amount; Amount)
                {
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                }
                field("Payment Amount"; "Payment Amount")
                {
                }
                field("POS Sale ID"; "POS Sale ID")
                {
                }
                field("Retail ID"; "Retail ID")
                {
                    Visible = false;
                }
            }
            part(SaleLines; "Archive POS Sale Lines Subpage")
            {
                Caption = 'POS Sale Lines';
                SubPageLink = "Register No." = FIELD("Register No."),
                              "Sales Ticket No." = FIELD("Sales Ticket No.");
            }
        }
        area(factboxes)
        {
            systempart(Control6014414; Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("View POS Sales Data")
            {
                Caption = 'View POS Sales Data';
                Image = XMLFile;

                trigger OnAction()
                var
                    POSQuoteMgt: Codeunit "POS Quote Mgt.";
                begin
                    ViewPOSSalesData(Rec);
                end;
            }
        }
    }

    procedure ViewPOSSalesData(ArchiveSalePOS: Record "Archive Sale POS")
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        StreamReader: DotNet npNetStreamReader;
        InStr: InStream;
        Path: Text;
        POSSalesData: Text;
    begin
        if not ArchiveSalePOS."POS Sales Data".HasValue then
            exit;

        ArchiveSalePOS.CalcFields("POS Sales Data");
        if IsWebClient() then begin
            ArchiveSalePOS."POS Sales Data".CreateInStream(InStr);
            StreamReader := StreamReader.StreamReader(InStr);
            POSSalesData := StreamReader.ReadToEnd();
            POSSalesData := NpXmlDomMgt.PrettyPrintXml(POSSalesData);
            Message(POSSalesData);
            exit;
        end;

        TempBlob.FromRecord(ArchiveSalePOS, ArchiveSalePOS.FieldNo("POS Sales Data"));
        Path := FileMgt.BLOBExport(TempBlob, TemporaryPath + ArchiveSalePOS."Sales Ticket No." + '.xml', false);
        HyperLink(Path);
    end;

    local procedure IsWebClient(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if ActiveSession.Get(ServiceInstanceId, SessionId) then
            exit(ActiveSession."Client Type" = ActiveSession."Client Type"::"Web Client");
        exit(false);
    end;
}

