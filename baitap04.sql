DELIMITER //
CREATE TRIGGER PreventDoubleBooking_Insert
BEFORE INSERT ON Appointments
FOR EACH ROW
BEGIN
    DECLARE overlap_count INT;
    SELECT COUNT(*) INTO overlap_count
    FROM Appointments
    WHERE doctor_id = NEW.doctor_id 
      AND appointment_date = NEW.appointment_date
      AND status != 'Cancelled';
      
    IF overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Bác sĩ đã có lịch hẹn vào khung giờ này';
    END IF;
END //
DELIMITER ;

-- TRIGGER 2: KIỂM SOÁT LÚC CẬP NHẬT
DELIMITER //
CREATE TRIGGER PreventDoubleBooking_Update
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
    DECLARE overlap_count INT;
    SELECT COUNT(*) INTO overlap_count
    FROM Appointments
    WHERE doctor_id = NEW.doctor_id 
      AND appointment_date = NEW.appointment_date
      AND status != 'Cancelled'
      AND appointment_id != NEW.appointment_id; 
    IF overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Bác sĩ đã có lịch hẹn vào khung giờ này';
    END IF;
END //
DELIMITER ;

-- Kiểm thử
-- Lịch mới đưa vào khung giờ hoàn toàn trống
INSERT INTO Appointments (doctor_id, appointment_date, status) VALUES (1,'2026-10-10 09:00:00', 'Pending'); 
-- Lịch mới đưa vào khung giờ trùng ca Pending
INSERT INTO Appointments (doctor_id, appointment_date, status) VALUES (1,'2026-10-10 09:00:00', 'Pending');
-- Lịch mới đưa vào khung giờ có ca Cancelled
INSERT INTO Appointments (doctor_id, appointment_date, status) VALUES (1,'2026-10-10 10:00:00', 'Pending');
-- Cập nhật trạng thái ca khám
UPDATE Appointments SET status = 'Completed' WHERE appointment_id = 1;