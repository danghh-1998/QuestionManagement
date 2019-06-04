package controller;

import java.net.URL;
import java.util.ArrayList;
import java.util.ResourceBundle;

import javafx.beans.property.SimpleBooleanProperty;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.geometry.Pos;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.Slider;
import javafx.scene.control.TableCell;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableColumn.CellDataFeatures;
import javafx.scene.control.TableColumn.CellEditEvent;
import javafx.scene.control.TableView;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.control.cell.CheckBoxTableCell;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.control.cell.TextFieldTableCell;
import javafx.scene.image.Image;
import javafx.stage.Stage;
import javafx.util.Callback;
import set_class.DapAnTracNghiem;
import set_class.TracNghiem;

/**
 * Class chứa các hàm giúp thêm câu hỏi trắc nghiệm và điều khiển các thành phần
 * giao diện của file fxml: ThemTracNghiem.fxml
 * 
 * @author Hoàng Hải Đăng
 */
public class ThemTracNghiemController implements Initializable {
	@FXML
	private TextArea areaDeBai;

	@FXML
	private TextField textMonHoc;

	@FXML
	private Button buttonThemChuong;

	@FXML
	private Button buttonThemDapAn;

	@FXML
	private Button buttonThemCauHoi;

	@FXML
	private Slider sliderDoKho;

	@FXML
	private Button buttonHuyBo;

	@FXML
	private TableView<Chuong> tableChuong;

	@FXML
	private TableView<DapAnTracNghiem> tableDapAn;

	@FXML
	private TableColumn<DapAnTracNghiem, String> colDapAn;

	@FXML
	private TableColumn<DapAnTracNghiem, Boolean> colDungSai;

	@FXML
	private TableColumn<Chuong, String> colChuong;
	private ObservableList<Chuong> dsChuong = FXCollections.observableArrayList(new Chuong(""));
	private ObservableList<DapAnTracNghiem> dsDapAn = FXCollections.observableArrayList(new DapAnTracNghiem("", false));

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
		tableDapAn.setEditable(true);
		colDapAn.setCellValueFactory(new PropertyValueFactory<DapAnTracNghiem, String>("dapAn"));
		colDapAn.setCellFactory(TextFieldTableCell.<DapAnTracNghiem>forTableColumn());
		colDapAn.setOnEditCommit(new EventHandler<CellEditEvent<DapAnTracNghiem, String>>() {

			@Override
			public void handle(CellEditEvent<DapAnTracNghiem, String> event) {
				((DapAnTracNghiem) event.getTableView().getItems().get(event.getTablePosition().getRow()))
						.setDapAn(event.getNewValue());
			}
		});

		colDungSai.setCellValueFactory(
				new Callback<CellDataFeatures<DapAnTracNghiem, Boolean>, ObservableValue<Boolean>>() {

					@Override
					public ObservableValue<Boolean> call(CellDataFeatures<DapAnTracNghiem, Boolean> arg) {
						DapAnTracNghiem dapAnTracNghiem = arg.getValue();
						SimpleBooleanProperty booleanPro = new SimpleBooleanProperty(dapAnTracNghiem.isDungSai());
						booleanPro.addListener(new ChangeListener<Boolean>() {

							@Override
							public void changed(ObservableValue<? extends Boolean> observable, Boolean oldValue,
									Boolean newValue) {
								dapAnTracNghiem.setDungSai(newValue);

							}

						});
						return booleanPro;
					}

				});
		colDungSai.setCellFactory(
				new Callback<TableColumn<DapAnTracNghiem, Boolean>, TableCell<DapAnTracNghiem, Boolean>>() {

					@Override
					public TableCell<DapAnTracNghiem, Boolean> call(TableColumn<DapAnTracNghiem, Boolean> arg0) {
						CheckBoxTableCell<DapAnTracNghiem, Boolean> cell = new CheckBoxTableCell<DapAnTracNghiem, Boolean>();
						cell.setAlignment(Pos.CENTER);
						return cell;
					}

				});
		tableDapAn.setItems(dsDapAn);
	}

	/**
	 * Thêm một dòng mới trong bảng danh sách Chương
	 * 
	 * @param event Khi người dùng nhấn Thêm chương
	 */
	public void themChuong(ActionEvent event) {
		dsChuong.add(new Chuong(""));
	}

	/**
	 * Thêm một dòng mới trong bảng danh sách đáp án
	 * 
	 * @param event Khi người dùng nhấn Thêm đáp án
	 */
	public void themDapAn(ActionEvent event) {
		dsDapAn.add(new DapAnTracNghiem("", false));
	}

	/**
	 * Trả về câu hỏi trấc nghiệm với các thuộc tính của câu hỏi được lấy trên giao
	 * diện
	 * 
	 * @return Câu hỏi trắc nghiệm
	 * 
	 */
	public TracNghiem themTracNghiem() {
		TracNghiem tracNghiem = new TracNghiem();
		tracNghiem.setMonHoc(textMonHoc.getText());
		ArrayList<String> chuong = new ArrayList<String>();
		for (int i = 0; i < dsChuong.size(); i++) {
			if (!dsChuong.get(i).getChuong().equals("")) {
				chuong.add(dsChuong.get(i).getChuong());
			}
		}
		tracNghiem.setChuong(chuong);
		tracNghiem.setDoKho(sliderDoKho.getValue() + "/10");
		tracNghiem.setDeBai(areaDeBai.getText());
		ArrayList<DapAnTracNghiem> dapAn = new ArrayList<DapAnTracNghiem>();
		for (int i = 0; i < dsDapAn.size(); i++) {
			if (!dsDapAn.get(i).getDapAn().equals("")) {
				dapAn.add(dsDapAn.get(i));
			}
		}
		tracNghiem.setDsDapAn(dapAn);
		return tracNghiem;
	}

	/**
	 * Kiểm tra xem các thuộc tính của câu hỏi đã đầy đủ chưa, nếu chưa thì yêu cầu
	 * nhập lại
	 * 
	 * @param event Khi người dùng nhấn Thêm câu hỏi
	 */
	public void kiemTra(ActionEvent event) {
		TracNghiem tracNghiem = new TracNghiem();
		tracNghiem.setMonHoc(textMonHoc.getText());
		ArrayList<String> chuong = new ArrayList<String>();
		for (int i = 0; i < dsChuong.size(); i++) {
			if (!dsChuong.get(i).getChuong().equals("")) {
				chuong.add(dsChuong.get(i).getChuong());
			}
		}
		tracNghiem.setChuong(chuong);
		tracNghiem.setDoKho(sliderDoKho.getValue() + "/10");
		tracNghiem.setDeBai(areaDeBai.getText());
		ArrayList<DapAnTracNghiem> dapAn = new ArrayList<DapAnTracNghiem>();
		for (int i = 0; i < dsDapAn.size(); i++) {
			if (!dsDapAn.get(i).getDapAn().equals("")) {
				dapAn.add(dsDapAn.get(i));
			}
		}
		tracNghiem.setDsDapAn(dapAn);
		boolean check = true;
		String canhBao = "Không được để trống ";
		if (tracNghiem.getMonHoc().equals("")) {
			check = false;
			canhBao += "Môn học ";
		}
		if (tracNghiem.getChuong().isEmpty()) {
			check = false;
			canhBao += "Chương ";
		}
		if (tracNghiem.getDoKho().charAt(0) == '0') {
			check = false;
			canhBao += "Độ khó ";
		}
		if (tracNghiem.getDeBai().equals("")) {
			check = false;
			canhBao += "Đề bài ";
		}
		if (tracNghiem.getDsDapAn().size() == 0) {
			check = false;
			canhBao += "Đáp án";
		}
		if (!check) {
			Alert alert = new Alert(Alert.AlertType.WARNING);
			alert.setTitle("Cảnh báo !");
			alert.setHeaderText(null);
			alert.setContentText(canhBao);
			((Stage) alert.getDialogPane().getScene().getWindow()).getIcons().add(new Image("/icon/warning.png"));
			alert.showAndWait();
		} else {
			Stage stage = (Stage) buttonThemCauHoi.getScene().getWindow();
			stage.close();
		}
	}

	/**
	 * Tắt cửa sổ thêm câu hỏi trắc nghiệm đồng thời hủy bỏ việc sửa câu hỏi trắc
	 * nghiệm
	 * 
	 * @param event Khi người dùng nhấn Hủy bỏ
	 */
	public void huyBo(ActionEvent event) {
		Stage stage = (Stage) buttonHuyBo.getScene().getWindow();
		stage.close();
	}
}
