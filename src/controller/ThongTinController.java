package controller;

import java.net.URL;
import java.util.ResourceBundle;

import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.control.TextArea;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;

/**
 * Class chứa các hàm giúp hiển thị thông tin ứng dụng đồng thời điều khiển các
 * thành phần giao diện trong file fxml: ThongTin.fxml
 * 
 * @author Hoàng Hải Đăng
 */
public class ThongTinController implements Initializable {
	@FXML
	Label label;

	@FXML
	TextArea textArea;

	/**
	 * Thiết lập các giá trị ban đầu cho các thành phần giao diện
	 */
	@Override
	public void initialize(URL location, ResourceBundle resources) {
		Image image = new Image(getClass().getResourceAsStream("/icon/icon.png"));
		label.setGraphic(new ImageView(image));
		label.setStyle("-fx-border-color:#444444;\n -fx-border-radius:5px;");
	}

}
