codeunit 6059866 NPRDemoHelperImplementation
{
    Access = Internal;
    procedure ResetLogs()
    var
        DataLogField: Record "NPR Data Log Field";
        DataLogRecord: Record "NPR Data Log Record";
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        TaskLogTask: Record "NPR Task Log (Task)";
        TaskOutputLog: Record "NPR Task Output Log";
        NcImportEntry: Record "NPR Nc Import Entry";
        NcTaskOutput: Record "NPR Nc Task Output";
        NcTask: Record "NPR Nc Task";
        ChangeLogEntry: Record "Change Log Entry";
        JobQueueLogEntry: Record "Job Queue Log Entry";
    begin
        begin
            ChangeLogEntry.DeleteAll(true);
            Commit();
        end;

        begin
            DataLogField.DeleteAll(true);
            Commit();
        end;

        begin
            DataLogRecord.DeleteAll(true);
            Commit();
        end;

        begin
            DataLogSubscriber.ModifyAll("Last Date Modified", 0DT);
            Commit();
        end;

        begin
            DataLogSubscriber.ModifyAll("Last Log Entry No.", 0);
            Commit();
        end;

        begin
            TaskOutputLog.DeleteAll(true);
            Commit();
        end;

        begin
            TaskLogTask.DeleteAll(true);
            Commit();
        end;

        begin
            NcTaskOutput.DeleteAll(true);
            Commit();
        end;

        begin
            NcTask.DeleteAll(true);
            Commit();
        end;

        begin
            NcImportEntry.DeleteAll();
            Commit();
        end;

        begin
            JobQueueLogEntry.DeleteAll();
            Commit();
        end;
    end;

    Procedure CreateMPOSUser(Username: Text; Password: Text; Company_Name: text; URL: text; POSUnit: code[20])
    var
        MPOSUser: Record "NPR MPOS QR Codes";
        Usersetup: Record "User Setup";
    begin

        if not UserSetup.Get(Username) then begin
            UserSetup.Init();
            UserSetup."User ID" := Username;
            Usersetup."NPR POS Unit No." := POSUnit;
            UserSetup.Insert(true);
        end;

        if not MPOSUser.Get(Username, Company_Name) then begin
            MPOSUser.init();
            MPOSUser.validate("User ID", Username);
            MPOSUser.validate(Password, Password);
            MPOSUser.validate(Company, Company_Name);
            MPOSUser.validate(Url, Url);
            MPOSUser.Insert(true);
            Commit();
        end;

        MPOSUser.SetDefaults(MPOSUser);
        MPOSUser.modify(true);
        Commit();

        MPOSUser.CreateQRCode(MPOSUser);
        MPOSUser.modify(true);
    end;

    Procedure UpdatePasswordPaymentGateway(PaymentCode: code[20]; "Demo Password": text)
    var
        MagPaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if MagPaymentGateway.get(PaymentCode) then
            MagPaymentGateway.SetApiPassword("Demo Password");
    end;


}