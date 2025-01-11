page 6184923 "NPR DE Submissions"
{
    ApplicationArea = NPRDEFiscal;
    Caption = 'DE Submissions';
    ContextSensitiveHelpPage = 'docs/fiscalization/germany/how-to/setup/';
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR DE Submission";
    PromotedActionCategories = 'New,Process,Report,Download';
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the POS store (establishment) for which this submission is created for.';
                }
                field("Establishment Id"; Rec."Establishment Id")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the identifier of the establishment for which this submission is created for.';
                }
                field(State; Rec.State)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the state of this submission.';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the date and time when this submission is created at Fiskaly.';
                }
                field("Generated At"; Rec."Generated At")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the date and time when this submission is generated at Fiskaly.';
                }
                field("Transmitted At"; Rec."Transmitted At")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the date and time when this submission is transmitted at Fiskaly.';
                }
                field("Errored At"; Rec."Errored At")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the date and time when this submission errored at Fiskaly.';
                }
                field("Error Description"; Rec.Error)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the description of the error.';
                }
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the identifier of this submission at Fiskaly.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the entry number.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateSubmission)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Create';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Creates the submission at Fiskaly.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.CreateSubmission('');
                    CurrPage.Update(false);
                end;
            }
            action(RetrieveSubmission)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Retrieve';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Retrieves the latest information about the submission from Fiskaly.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.RetrieveSubmission(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(TriggerSubmissionTransmission)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Trigger Transmission';
                Enabled = Rec.State = Rec.State::READY_FOR_TRANSMISSION;
                Image = SendConfirmation;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Triggers the transmission of submission at Fiskaly. We have entered into an agreement with our client, whose data records we transmit to the tax authorities via the SIGN DE service provided by fiskaly Deutschland GmbH. In accordance with §87d AO , we act as the client''s authorized representative for the data transmission to the tax authority. Prior to the transmission of the data record via the SIGN DE service, we provided the data record to our client in an easily verifiable format for their review, approval, and verification that the data records are complete and accurate, which the client has confirmed. Before transmitting the data record, we verified the identification of our client as the principal (verification of identity and address). We have documented the relevant information and the client''s confirmation of the data records, in an appropriate format and can provide evidence at any time of the identity of the principal responsible for the data transmission, as well as the confirmation of the data records. The records of this information will be retained for five years following the end of the calendar year in which the last TV data transmission to the tax authority occurred.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.TriggerSubmissionTransmission(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CancelSubmissionTransmission)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Cancel Transmission';
                Enabled = Rec.State = Rec.State::TRANSMISSION_PENDING;
                Image = VoidElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Cancels the transmission of submission at Fiskaly.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.CancelSubmissionTransmission(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(DownloadSubmissionXMLFile)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'XML File';
                Image = XMLFile;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                ToolTip = 'Downloads the XML file of this submission. Contains the submitted information in the XML format required for its transmission to the fiscal authorities.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.DownloadSubmissionXMLFile(Rec);
                end;
            }
            action(DownloadERiCSubmissionValidationPreviewPDFFile)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'ERiC Validation Preview PDF File';
                Enabled = Rec.State = Rec.State::VALIDATION_SUCCEEDED;
                Image = SendAsPDF;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                ToolTip = 'Downloads the ERiC validation preview PDF file of this submission. When validation is successful, this file contains a preview of the submission, generated by ERiC, in the PDF format.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.DownloadERiCSubmissionValidationPreviewPDFFile(Rec);
                end;
            }
            action(DownloadERiCSubmissionValidationXMLFile)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'ERiC Validation XML File';
                Enabled = (Rec.State = Rec.State::INTERNAL_VALIDATION_FAILED) or (Rec.State = Rec.State::EXTERNAL_VALIDATION_FAILED);
                Image = CreateXMLFile;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                ToolTip = 'Downloads the ERiC validation XML file of this submission. When validation has failed, this file contains a set of errors in the XML format.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.DownloadERiCSubmissionValidationXMLFile(Rec);
                end;
            }
            action(DownloadERiCSubmissionTransmissionPDFFile)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'ERiC Transmission PDF File';
                Enabled = Rec.State = Rec.State::TRANSMISSION_SUCCEEDED;
                Image = SendAsPDF;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                ToolTip = 'Downloads the ERiC transmission PDF file of this submission. When transmission is successful, this file contains the submission, generated by ERiC, in the PDF format.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.DownloadERiCSubmissionTransmissionPDFFile(Rec);
                end;
            }
            action(DownloadERiCELSTERSubmissionTransmissionXMLFile)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'ERiC/ELSTER Transmission XML File';
                Enabled = Rec.State = Rec.State::TRANSMISSION_FAILED;
                Image = CreateXMLFile;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                ToolTip = 'Downloads the ERiC/ELSTER transmission XML file of this submission. When transmission has failed, this file contains a set of errors in the XML format.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.DownloadERiCELSTERSubmissionTransmissionXMLFile(Rec);
                end;
            }
            action(RetrieveSubmissions)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Refresh Submissions';
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Copies information about the available submissions from Fiskaly.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.RetrieveSubmissions();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
