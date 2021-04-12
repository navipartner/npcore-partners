xmlport 6060109 "NPR TM Offline Ticket Valid."
{
    // TM1.22/NPKNAV/20170612  CASE 274464 Transport T0007 - 12 June 2017

    Caption = 'Offline Ticket Validation';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(tickets)
        {
            tableelement(tmpticketofflinevalidation; "NPR TM Offline Ticket Valid.")
            {
                MinOccurs = Zero;
                XmlName = 'validate_offline';
                UseTemporary = true;
                fieldelement(ticket_reference; TmpTicketOfflineValidation."Ticket Reference No.")
                {
                    fieldattribute(type; TmpTicketOfflineValidation."Ticket Reference Type")
                    {
                        Occurrence = Optional;
                    }
                }
                fieldelement(member_reference; TmpTicketOfflineValidation."Member Reference No.")
                {
                    MinOccurs = Zero;
                    fieldattribute(type; TmpTicketOfflineValidation."Member Reference Type")
                    {
                        Occurrence = Optional;
                    }
                }
                fieldelement(admission_code; TmpTicketOfflineValidation."Admission Code")
                {
                }
                textelement(admission_at)
                {
                    MaxOccurs = Once;
                    fieldattribute(date; TmpTicketOfflineValidation."Event Date")
                    {
                    }
                    fieldattribute(time; TmpTicketOfflineValidation."Event Time")
                    {
                    }
                }
                fieldelement(external_reference; TmpTicketOfflineValidation."Import Reference Name")
                {
                }

                trigger OnBeforeInsertRecord()
                begin
                    EntryNo += 1;
                    TmpTicketOfflineValidation."Entry No." := EntryNo;
                end;
            }
            textelement(validate_offline_result)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(summary)
                {
                    textelement(importbatchno)
                    {
                        XmlName = 'import_reference_no';

                        trigger OnBeforePassVariable()
                        begin
                            ImportBatchNo := Format(ImportRefNo, 0, 9);
                        end;
                    }
                    textelement(validtickets)
                    {
                        XmlName = 'valid_count';
                    }
                    textelement(invalidtickets)
                    {
                        XmlName = 'invalid_count';
                    }
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    var
        EntryNo: Integer;
        ImportRefNo: Integer;

    procedure ProcessImportedRecords()
    var
        OfflineTicketValidation: Record "NPR TM Offline Ticket Valid.";
        OfflineTicketValidationMgr: Codeunit "NPR TM Offline Ticket Valid.";
    begin

        if (not TmpTicketOfflineValidation.FindSet()) then
            exit;

        OfflineTicketValidation.SetCurrentKey("Import Reference No.");
        OfflineTicketValidation.LockTable();
        if (OfflineTicketValidation.FindLast()) then;
        ImportRefNo := OfflineTicketValidation."Import Reference No." + 1;

        OfflineTicketValidation.Reset();

        repeat
            Clear(OfflineTicketValidation);
            OfflineTicketValidation.TransferFields(TmpTicketOfflineValidation, false);
            OfflineTicketValidation."Imported At" := CurrentDateTime;
            OfflineTicketValidation."Import Reference No." := ImportRefNo;
            OfflineTicketValidation.Insert();
        until (TmpTicketOfflineValidation.Next() = 0);
        Commit();

        OfflineTicketValidationMgr.ProcessImportBatch(ImportRefNo);
        Commit();

        OfflineTicketValidation.Reset();
        OfflineTicketValidation.SetCurrentKey("Import Reference No.");
        OfflineTicketValidation.SetFilter("Import Reference No.", '=%1', ImportRefNo);
        OfflineTicketValidation.SetFilter("Process Status", '=%1', OfflineTicketValidation."Process Status"::VALID);
        ValidTickets := Format(OfflineTicketValidation.Count(), 0, 9);

        OfflineTicketValidation.SetFilter("Process Status", '=%1', OfflineTicketValidation."Process Status"::INVALID);
        InvalidTickets := Format(OfflineTicketValidation.Count(), 0, 9);

        TmpTicketOfflineValidation.DeleteAll();
    end;
}

