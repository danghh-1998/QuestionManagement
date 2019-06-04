package controller;

import java.net.URL;
import java.util.ArrayList;
import java.util.ResourceBundle;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.Slider;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableColumn.CellEditEvent;
import javafx.scene.control.TableView;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.control.cell.TextFieldTableCell;
import javafx.scene.image.Image;
import javafx.stage.Stage;
import set_class.TuLuan;

/**
 * Class chứa các hàm giúp thêm câu hỏi tự luận và điều khiển các thành phần
 * giao diện trong file fxml: ThemTuLuan.fxml
 * 
 * @author Hoàng Hải Đăng
 */
public class ThemTuLuanController implements Initializable {
	@FXML
	private TextArea areaDeBai;

	@FXML
	private TextField textMonHoc;

	@FXML
	private TableView<Chuong> tableChuong;

	@FXML
	private Button buttonThemChuong;

	@FXML
	private Button buttonThemCauHoi;

	@FXML
	private Slider sliderDoKho;

	@FXML
	private TextArea areaDapAn;

	@FXML
	private Button buttonHuyBo;

	@FXML
	private TableColumn<Chuong, String> colChuong;

	private ObservableList<Chuong> dsChuong = FXCollections.observableArrayList(new Chuong(""));

	/**
	 * Thiết lập các giá trị ban đầu cho các thành phần giao diện
	 */
	@Override
	public void initialize(URL location, ResourceBundle resources) {
		tableChuong.setEditable(true);
		colChuong.setCellValueFactory(new PropertyValueFactory<Chuong, String>("chuong"));
		colChuong.setCellFactory(TextFieldTableCell.<Chuong>forTableColumn());
		colChuong.setOnEditCommit(new EventHandler<CellEditEvent<Chuong, String>>() {

			@Override
			public void handle(CellEditEvent<Chuong, String> event) {
				((Chuong) event.getTableView().getItems().get(event.getTablePosition().getRow()))
						.setChuong(event.getNewValue());
			}

		});
		tableChuong.setItems(dsChuong);
	}

	/**
	 * Thêm một dòng mới vào bảng danh sách chương
	 * 
	 * @param event Khi người dùng nhấn Thêm chương
	 */
	public void themChuong(ActionEvent event) {
		Chuong chuong = new Chuong("");
		dsChuong.add(chuong);
	}

	/**
	 * Kiểm tra xem các thuộc tính của câu hỏi đã đầy đủ chưa, nếu chưa thì yêu cầu
	 * nhập lại
	 * 
	 * @param event Khi người dùng nhấn Thêm câu hỏi
	 */
	public void kiemTra(ActionEvent event) {
		TuLuan tuLuan = new TuLuan();
		tuLuan.setMonHoc(textMonHoc.getText());
		tuLuan.setDoKho(sliderDoKho.getValue() + "/10");
		tuLuan.setDeBai(areaDeBai.getText());
		tuLuan.setDapAn(areaDapAn.getText());
		ArrayList<String> chuong = new ArrayList<String>();
		for (int i = 0; i < dsChuong.size(); i++) {
			if (!dsChuong.get(i).getChuong().equals("")) {
				chuong.add(dsChuong.get(i).getChuong());
			}
		}
		tuLuan.setChuong(chuong);
		boolean check = true;
		String canhBao = "Không thể để trống ";
		if (tuLuan.getMonHoc().equals("")) {
			check = false;
			canhBao += "Môn học ";
		}
		if (tuLuan.getChuong().isEmpty()) {
			check = false;
			canhBao += "Chương ";
		}
		if (tuLuan.getDoKho().charAt(0) == '0') {
			check = false;
			canhBao += "Độ khó ";
		}
		if (tuLuan.getDeBai().equals("")) {
			check = false;
			canhBao += "Đề bài ";
		}
		if (tuLuan.getDapAn().equals("")) {
			check = false;
			canhBao += "Đáp án";
		}
		if (!check) {
			Alert alert = new Alert(Alert.AlertType.WARNING);
			alert.setHeaderText(null);
			alert.setContentText(canhBao);
			alert.setTitle("Cảnh báo !");
			((Stage) alert.getDialogPane().getScene().getWindow()).getIcons().add(new Image("/icon/warning.png"));
			alert.showAndWait();
		} else {
			Stage stage = (Stage) buttonThemCauHoi.getScene().getWindow();
			stage.close();
		}
	}

	/**
	 * Trả về câu hỏi tự luận với các thuộc tính của câu hỏi được lấy trên giao diện
	 * 
	 * @return Câu hỏi tự luận
	 * 
	 */
	public TuLuan themTuLuan() {
		TuLuan tuLuan = new TuLuan();
		tuLuan.setMonHoc(textMonHoc.getText());
		tuLuan.setDoKho(sliderDoKho.getValue() + "/10");
		tuLuan.setDeBai(areaDeBai.getText());
		tuLuan.setDapAn(areaDapAn.getText());
		ArrayList<String> chuong = new ArrayList<String>();
		for (int i = 0; i < dsChuong.size(); i++) {
			if (!dsChuong.get(i).getChuong().equals("")) {
				chuong.add(dsChuong.get(i).getChuong());
			}
		}
		tuLuan.setChuong(chuong);
		return tuLuan;
	}

	/**
	 * Tắt cửa sổ thêm câu hỏi tự luận đồng thời hủy bỏ việc thêm câu hỏi tự luận
	 * 
	 * @param event Khi người dùng nhấn Hủy bỏ
	 */
	public void huyBo(ActionEvent event) {
		Stage stage = (Stage) buttonHuyBo.getScene().getWindow();
		stage.close();
	}
}
