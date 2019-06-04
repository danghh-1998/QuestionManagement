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
 * Class chứa các hàm cho phép chỉnh sửa câu hỏi tự luận và điều khiển các thành
 * phân giao diện trong file fxml: ChinhSuaTuLuan.fxml
 * 
 * @author Hoang Hai Dang
 */
public class ChinhSuaTuLuanController implements Initializable {
	@FXML
	private TextArea areaDeBai;

	@FXML
	private TextField textMonHoc;

	@FXML
	private TableView<Chuong> tableChuong;

	@FXML
	private TableColumn<Chuong, String> colChuong;

	@FXML
	private Button buttonThemChuong;

	@FXML
	private Slider sliderDoKho;

	@FXML
	private TextArea areaDapAn;

	@FXML
	private Button buttonChinhSua;

	@FXML
	private Button buttonHuyBo;

	private ObservableList<Chuong> dsChuong = FXCollections.observableArrayList();

	/**
	 * Thiết lập giá trị cho TextField Môn học
	 * 
	 * @param monHoc Môn học
	 */
	public void setTextMonHoc(String monHoc) {
		this.textMonHoc.setText(monHoc);
	}

	/**
	 * Thiết lập giá trị cho bảng chứa danh sách chương
	 * 
	 * @param chuong Danh sách các chương
	 */
	public void setTableChuong(ArrayList<String> chuong) {
		for (int i = 0; i < chuong.size(); i++) {
			dsChuong.add(new Chuong(chuong.get(i)));
		}
	}

	/**
	 * Thiết lập giá trị cho Slider Độ khó
	 * 
	 * @param doKho Độ khó
	 */
	public void setSliderDoKho(String doKho) {
		this.sliderDoKho.setValue(Character.getNumericValue(doKho.charAt(0)));
	}

	/**
	 * Thiết lập giá trị cho TextArea Đề bài
	 * 
	 * @param deBai ĐỀ bài
	 */
	public void setAreaDeBai(String deBai) {
		this.areaDeBai.setText(deBai);
	}

	/**
	 * Thiết lập giá trị cho TextArea Đáp án
	 * 
	 * @param dapAn Đáp án
	 */
	public void setAreaDapAn(String dapAn) {
		this.areaDapAn.setText(dapAn);
	}

	/**
	 * Cài đặt các giá trị ban đầu cho các thành phần giao diện
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
	 * Khi người dùng nhấn Thêm chương, một dòng mới sẽ được thêm trong bảng danh
	 * sách chương cho phép nhập thêm chương
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
	 * @param event Khi người nhấn Chỉnh sửa
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
			alert.setTitle("Cảnh báo !");
			((Stage) alert.getDialogPane().getScene().getWindow()).getIcons().add(new Image("/icon/warning.png"));
			alert.setContentText(canhBao);
			alert.showAndWait();
		} else {
			Stage stage = (Stage) buttonChinhSua.getScene().getWindow();
			stage.close();
		}
	}

	/**
	 * Hàm trả về một câu hỏi tự luận với các thuộc tính của câu hỏi được lấy trên
	 * giao diện
	 * 
	 * @return câu hỏi tự luận
	 */
	public TuLuan chinhSuaTuLuan() {
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
	 * Tắt cửa sổ chỉnh sửa câu hỏi tự luận đồng thời hủy bỏ việc sửa câu hỏi tự
	 * luận
	 * 
	 * @param event Khi người dùng nhấn Hủy bỏ
	 */
	public void huyBo(ActionEvent event) {
		Stage stage = (Stage) buttonHuyBo.getScene().getWindow();
		stage.close();
	}

}
