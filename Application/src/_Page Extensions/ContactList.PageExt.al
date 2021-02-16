pageextension 6014453 "NPR Contact List" extends "Contact List"
{
    // NPR5.23/BHR/20160329 CASE 222711 Added PhoneLookup Action.
    // NPR5.29/TJ /20170125 CASE 263507 Moved code from PhoneLookup action to a subscriber and also renamed that action from default to PhoneLookup
    // NPR5.38/BR /20171117 CASE 295255 Added Action POS Entries
    actions
    {
        addafter(Statistics)
        {
            action("NPR POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entries action';
            }
        }
        addafter(NewSalesQuote)
        {
            action("NPR PhoneLookup")
            {
                Caption = 'PhoneLookup';
                Image = ImportLog;
                ApplicationArea = All;
                ToolTip = 'Executes the PhoneLookup action';
            }
        }

        addfirst(Processing)
        {
            group("NPR FacialRecognition")
            {
                Caption = 'Facial Recognition';
                Image = PersonInCharge;
                action("NPR ImportFace")
                {
                    Caption = 'Import Face Image';
                    ApplicationArea = All;
                    Image = Picture;
                    ToolTip = 'Executes the Import Face Image action';

                    trigger OnAction()
                    var
                        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
                        FacialRecognitionDetect: Codeunit "NPR Detect Face";
                        FacialRecognitionPersonGroup: Codeunit "NPR Create Person Group";
                        FacialRecognitionPerson: Codeunit "NPR Create Person";
                        FacialRecognitionPersonFace: Codeunit "NPR Add Person Face";
                        FacialRecognitionTrainPersonGroup: Codeunit "NPR Train Person Group";
                        ImageMgt: Codeunit "NPR Face Image Mgt.";
                        ImageFileStream: InStream;
                        EntryNo: Integer;
                        CalledFrom: Option Contact,Member;
                        NotSetUp: Label 'Facial Recognition is not active. \It can be enabled from the Facial Recognition setup.';
                        ConnectionError: Label 'The API can''t be reached. \Please contact your administrator.';
                        NoNameError: Label 'Contact information is not complete. \Action aborted.';
                        IsError: Boolean;
                        ErroMessage: Text;
                    begin
                        if not FacialRecognitionSetup.FindFirst() or not FacialRecognitionSetup.Active then begin
                            Message(NotSetUp);
                            exit;
                        end;

                        if not FacialRecognitionPersonGroup.GetPersonGroups() then begin
                            Message(ConnectionError);
                            exit;
                        end;

                        if Rec."Name" = '' then begin
                            Message(NoNameError);
                            exit;
                        end;

                        FacialRecognitionPersonGroup.CreatePersonGroup(Rec, false);

                        FacialRecognitionPerson.CreatePerson(Rec, false);

                        FacialRecognitionDetect.DetectFace(Rec, ImageFileStream, EntryNo, false, CalledFrom::Contact, IsError, ErroMessage);

                        if IsError then begin
                            Message(ErroMessage);
                            exit;
                        end;

                        if FacialRecognitionPersonFace.AddPersonFace(Rec, ImageFileStream, EntryNo) then begin
                            FacialRecognitionTrainPersonGroup.TrainPersonGroup(Rec, false);
                            ImageMgt.UpdateRecordImage("No.", CalledFrom::Contact, ImageFileStream);
                        end else
                            Message(ErroMessage);
                    end;
                }

                action("NPR IdentifyFace")
                {
                    Caption = 'Identify Person';
                    ApplicationArea = All;
                    Image = AnalysisView;
                    ToolTip = 'Executes the Identify Person action';

                    trigger OnAction()
                    var
                        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
                        FacialRecognitionIdentify: Codeunit "NPR Identify Person";
                        NotSetUp: Label 'Facial Recognition is not active. \It can be enabled from the Facial Recognition setup.';
                        CalledFrom: Option Contact,Member;
                    begin
                        if not FacialRecognitionSetup.FindFirst() or not FacialRecognitionSetup.Active then begin
                            Message(NotSetUp);
                            exit;
                        end;

                        FacialRecognitionIdentify.IdentifyPersonFace(CalledFrom::Contact);
                    end;
                }
            }
        }
    }
}