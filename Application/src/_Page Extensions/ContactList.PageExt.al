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
            }
        }
        addafter(NewSalesQuote)
        {
            action("NPR PhoneLookup")
            {
                Caption = 'PhoneLookup';
                Image = ImportLog;
                ApplicationArea = All;
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

                    trigger OnAction()
                    var
                        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
                        FacialRecognitionDetect: Codeunit "NPR Detect Face";
                        FacialRecognitionPersonGroup: Codeunit "NPR Create Person Group";
                        FacialRecognitionPerson: Codeunit "NPR Create Person";
                        FacialRecognitionPersonFace: Codeunit "NPR Add Person Face";
                        FacialRecognitionTrainPersonGroup: Codeunit "NPR Train Person Group";
                        ImageMgt: Codeunit "NPR Image Mgt.";
                        ImageFilePath: Text;
                        EntryNo: Integer;
                        CalledFrom: Option Contact,Member;
                        NotSetUp: Label 'Facial Recognition is not active. \It can be enabled from the Facial Recognition setup.';
                        ImgCantBeProcessed: Label 'Media not supported. \Image can''t be processed. \Please use .jpg or .png images .';
                        ConnectionError: Label 'The API can''t be reached. \Please contact your administrator.';
                        NoNameError: Label 'Contact information is not complete. \Action aborted.';
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

                        FacialRecognitionDetect.DetectFace(Rec, ImageFilePath, EntryNo, false, CalledFrom::Contact);
                        case ImageFilePath of
                            '':
                                exit;
                            'WrongExtension':
                                begin
                                    Message(ImgCantBeProcessed);
                                    exit;
                                end;
                        end;

                        if FacialRecognitionPersonFace.AddPersonFace(Rec, ImageFilePath, EntryNo) then begin
                            FacialRecognitionTrainPersonGroup.TrainPersonGroup(Rec, false);
                            ImageMgt.UpdateRecordImage("No.", CalledFrom::Contact, ImageFilePath);
                        end else
                            Message(ImgCantBeProcessed);
                    end;
                }

                action("NPR IdentifyFace")
                {
                    Caption = 'Identify Person';
                    ApplicationArea = All;
                    Image = AnalysisView;

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