import logging
from typing import Optional, List, Dict
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os

class NotificationService:
    """
    Production-ready notification service.
    Supports email notification (extendable for SMS, LINE, etc.)
    """

    def __init__(self):
        self.smtp_host = os.getenv("SMTP_HOST", "smtp.gmail.com")
        self.smtp_port = int(os.getenv("SMTP_PORT", 587))
        self.smtp_user = os.getenv("SMTP_USER")
        self.smtp_password = os.getenv("SMTP_PASSWORD")
        self.sender_email = os.getenv("SENDER_EMAIL", self.smtp_user)
        self.enabled = all([self.smtp_user, self.smtp_password, self.sender_email])

    def send_email(
        self,
        to_emails: List[str],
        subject: str,
        body: str,
        html: Optional[str] = None,
        cc: Optional[List[str]] = None,
        bcc: Optional[List[str]] = None,
        attachments: Optional[List[Dict[str, bytes]]] = None,
    ) -> bool:
        """
        Send email notification (production-ready).
        """
        if not self.enabled:
            logging.warning("Email notification is not enabled (missing SMTP config).")
            return False
        try:
            msg = MIMEMultipart("mixed")
            msg["Subject"] = subject
            msg["From"] = self.sender_email
            msg["To"] = ", ".join(to_emails)
            if cc:
                msg["Cc"] = ", ".join(cc)
            recipients = to_emails + (cc if cc else []) + (bcc if bcc else [])

            # Attach plain and html parts
            alt_part = MIMEMultipart("alternative")
            alt_part.attach(MIMEText(body, "plain", "utf-8"))
            if html:
                alt_part.attach(MIMEText(html, "html", "utf-8"))
            msg.attach(alt_part)

            # Attach files if any
            if attachments:
                from email.mime.application import MIMEApplication
                for att in attachments:
                    part = MIMEApplication(att["content"])
                    part.add_header("Content-Disposition", "attachment", filename=att["filename"])
                    msg.attach(part)

            with smtplib.SMTP(self.smtp_host, self.smtp_port) as server:
                server.starttls()
                server.login(self.smtp_user, self.smtp_password)
                server.sendmail(self.sender_email, recipients, msg.as_string())
            logging.info(f"Email sent to {recipients}")
            return True
        except Exception as e:
            logging.error(f"Failed to send email: {e}")
            return False

    def send_notification(self, user_email: str, subject: str, message: str, html: Optional[str] = None, attachments: Optional[List[Dict[str, bytes]]] = None) -> bool:
        """
        High-level notification for a single user (email).
        """
        return self.send_email([user_email], subject, message, html=html, attachments=attachments)

    # Extend here for SMS, LINE, push notification, etc.

# หมายเหตุ:
# - ใช้ environment variable สำหรับ SMTP config (production-ready)
# - รองรับไฟล์แนบ (attachments) และ multi-part email
# - Logging ครบถ้วน, ไม่มี conflict กับระบบอื่น
# - พร้อมสำหรับ production, maintain ง่าย, ขยายต่อยอดได้ (LINE, SMS,
