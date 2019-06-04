package controller;

import java.awt.Desktop;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.ResourceBundle;

import database_access_object.DAO;
import javafx.beans.property.SimpleBooleanProperty;
import javafx.beans.value.ObservableValue;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.geometry.Pos;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.ListView;
import javafx.scene.control.MenuItem;
import javafx.scene.control.Slider;
import javafx.scene.control.TableCell;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableColumn.CellDataFeatures;
import javafx.scene.control.TableView;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.control.TreeItem;
import javafx.scene.control.TreeView;
import javafx.scene.control.cell.CheckBoxTableCell;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.control.cell.TextFieldTableCell;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseButton;
import javafx.scene.input.MouseEvent;
import javafx.stage.Modality;
import javafx.stage.Stage;
import javafx.util.Callback;
import set_class.DapAnTracNghiem;
import set_class.TracNghiem;

/**
 * Class chứa các hàm cho phép hiển thị danh sách các câu hỏi trắc nghiệm, hiển
 * thị giao diện thêm, sửa xóa câu hỏi trắc nghiệm, giao diện tạo đề thi bằng
 * tay hoặc ngẫu nhiên, hiển thị thông tin ứng dụng, hướng dẫn sử dụng đồng thời
 * điều khiển các thành phần giao diện trong file fxml: XemTracNghiem.fxml
 * 
 * @author Hoàng Hải Đăng
 */
public class XemTracNghiemController implements Initializable {
	@FXML
	private TextArea areaDeBai;

	@FXML
	private MenuItem menuItemTuLuan;

	@FXML
	private TextField textMonHoc;

	@FXML
	private Slider sliderDoKho;

	@FXML
	private ListView<String> listChuong;

	@FXML
	private TableView<DapAnTracNghiem> tableDapAn;

	@FXML
	private TreeView<TracNghiem> treeTracNghiem;

	@FXML
	private TableColumn<DapAnTracNghiem, String> colDapAn;

	@FXML
	private TableColumn<DapAnTracNghiem, Boolean> colDungSai;

	@FXML
	private MenuItem menuTaoDeThiBangTay;

	@FXML
	private MenuItem menuItemTaoDeThiNgauNhien;

	private DAO dao = new DAO();
	private ArrayList<TracNghiem> dsTracNghiem = dao.getDsTracNghiem();
	private ObservableList<DapAnTracNghiem> dsDapAn = FXCollections.observableArrayList();
	private ObservableList<String> dsChuongHienThi = FXCollections.observableArrayList();

	/**
	 * Thiết lập các giá trị ban đầu cho các thành phần giao diện
	 */
	@Override
	public void initialize(URL location, ResourceBundle resources) {
		TreeItem<TracNghiem> rootTracNghiem = new TreeItem<TracNghiem>();
		Image image = new Image(getClass().getResourceAsStream("/icon/CauHoi.png"));
		for (TracNghiem tracNghiem : dsTracNghiem) {
			TreeItem<TracNghiem> item = new TreeItem<TracNghiem>(tracNghiem);
			item.setGraphic(new ImageView(image));
			rootTracNghiem.getChildren().add(item);
		}
		treeTracNghiem.setRoot(rootTracNghiem);
		treeTracNghiem.setShowRoot(false);
		colDapAn.setCellValueFactory(new PropertyValueFactory<DapAnTracNghiem, String>("dapAn"));
		colDapAn.setCellFactory(TextFieldTableCell.<DapAnTracNghiem>forTableColumn());
		colDungSai.setCellValueFactory(
				new Callback<CellDataFeatures<DapAnTracNghiem, Boolean>, ObservableValue<Boolean>>() {

					@Override
					public ObservableValue<Boolean> call(CellDataFeatures<DapAnTracNghiem, Boolean> arg) {
						DapAnTracNghiem dapAnTracNghiem = arg.getValue();
						SimpleBooleanProperty booleanPro = new SimpleBooleanProperty(dapAnTracNghiem.isDungSai());
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

	}

	/**
	 * Thay đổi từ cửa sổ hiển thị danh sách câu hỏi trắc nghiệm sang hiển thị danh
	 * sách câu hỏi tự luận
	 * 
	 * @param event Khi người dùng chọn Menu Câu hỏi và chọn Câu hỏi tự luận
	 * @throws IOException IOException
	 */
	public void changeScene(ActionEvent event) throws IOException {
		Stage stage = (Stage) areaDeBai.getScene().getWindow();
		Parent root = FXMLLoader.load(getClass().getResource("/fxml_file/XemTuLuan.fxml"));
		Scene scene = new Scene(root);
		stage.setScene(scene);
		stage.getIcons().add(new Image("/icon/iconWindows.png"));
		stage.setTitle("Câu hỏi tự luận");
		stage.show();
	}

	/**
	 * Hiển thị chi tiết các thuộc tính của câu hỏi được chọn
	 * 
	 * @param mouseEvent Khi người dùng chọn một câu hỏi trong danh sách câu hỏi trắc nghiệm
	 */
	public void hienThi(MouseEvent mouseEvent) {
		if (mouseEvent.getButton() == MouseButton.PRIMARY) {
			dsChuongHienThi = FXCollections.observableArrayList();
			dsDapAn = FXCollections.observableArrayList();
			TreeItem<TracNghiem> item = treeTracNghiem.getSelectionModel().getSelectedItem();
			if (item != null) {
				TracNghiem tracNghiem = item.getValue();
				textMonHoc.setText(tracNghiem.getMonHoc());
				dsChuongHienThi = FXCollections.observableArrayList(tracNghiem.getChuong());
				sliderDoKho.setValue(Character.getNumericValue(tracNghiem.getDoKho().charAt(0)));
				areaDeBai.setText(tracNghiem.getDeBai());
				dsDapAn = FXCollections.observableArrayList(tracNghiem.getDsDapAn());
				tableDapAn.setItems(dsDapAn);
				listChuong.setItems(dsChuongHienThi);
			}
		}
	}

	/**
	 * Hiển thị giao diện thêm câu hỏi trắc nghiệm, thêm câu hỏi đó vào cơ sở dữ
	 * liệu nếu câu hỏi đó có đầy đủ các thuộc tính
	 * 
	 * @param event Khi người dùng nhấn chuột phải và chọn Thêm câu hỏi
	 * @throws IOException IOException
	 * @throws SQLException SQLException
	 */
	public void themTracNghiem(ActionEvent event) throws IOException, SQLException {
		FXMLLoader loader = new FXMLLoader();
		loader.setLocation(getClass().getResource("/fxml_file/ThemTracNghiem.fxml"));
		Stage stage = new Stage();
		Scene scene = new Scene(loader.load());
		stage.setScene(scene);
		stage.getIcons().add(new Image("/icon/iconWindows.png"));
		stage.initModality(Modality.WINDOW_MODAL);
		stage.initOwner((Stage) areaDeBai.getScene().getWindow());
		stage.setResizable(false);
		stage.setTitle("Thêm câu hỏi trắc nghiệm");
		stage.showAndWait();
		ThemTracNghiemController themTracNghiemController = loader.getController();
		TracNghiem tracNghiem = themTracNghiemController.themTracNghiem();
		boolean check = true;
		if (tracNghiem.getMonHoc().equals("")) {
			check = false;
		}
		if (tracNghiem.getChuong().isEmpty()) {
			check = false;
		}
		if (tracNghiem.getDoKho().charAt(0) == '0') {
			check = false;
		}
		if (tracNghiem.getDeBai().equals("")) {
			check = false;
		}
		if (tracNghiem.getDsDapAn().size() == 0) {
			check = false;
		}
		if (check) {
			dao.themTracNghiem(tracNghiem);
			tracNghiem.setId(dao.getLastIDTracNghiem());
			Image image = new Image(getClass().getResourceAsStream("/icon/CauHoi.png"));
			treeTracNghiem.getRoot().getChildren().add(new TreeItem<TracNghiem>(tracNghiem, new ImageView(image)));
		}
	}

	/**
	 * Xóa câu hỏi được chọn khỏi danh sách câu hỏi và cơ sở dữ liệu
	 * 
	 * @param event Khi người dùng lựa chọn một câu hỏi, nhấn chuột phải và chọn Xóa
	 *              câu hỏi
	 * @throws SQLException SQLException
	 */
	public void xoaTracNghiem(ActionEvent event) throws SQLException {
		TreeItem<TracNghiem> item = treeTracNghiem.getSelectionModel().getSelectedItem();
		if (item != null) {
			dao.xoaTracNghiem(Integer.parseInt(item.getValue().getId()));
			treeTracNghiem.getRoot().getChildren().remove(item);
			textMonHoc.setText("");
			listChuong.getItems().clear();
			sliderDoKho.setValue(0);
			areaDeBai.setText("");
			dsDapAn.clear();
		}
	}

	/**
	 * Hiển thị giao diện Chỉnh Sửa câu hỏi trắc nghiệm, thay đổi các giá trị của
	 * thuộc tính câu hỏi được chọn trong cơ sở dữ liệu
	 * 
	 * @param event Khi người dùng lựa chọn một câu hỏi, nhấn chuột phải và chọn
	 *              Chỉnh sửa câu hỏi
	 * @throws IOException IOException
	 * @throws NumberFormatException NumberFormatException
	 * @throws SQLException SQLException
	 */
	public void chinhSuaTracNghiem(ActionEvent event) throws IOException, NumberFormatException, SQLException {
		FXMLLoader loader = new FXMLLoader();
		loader.setLocation(getClass().getResource("/fxml_file/ChinhSuaTracNghiem.fxml"));
		Stage stage = new Stage();
		Scene scene = new Scene(loader.load());
		stage.setScene(scene);
		stage.getIcons().add(new Image("/icon/iconWindows.png"));
		stage.initModality(Modality.WINDOW_MODAL);
		stage.initOwner(areaDeBai.getScene().getWindow());
		stage.setResizable(false);
		stage.setTitle("Chình sửa câu hỏi trắc nghiệm");
		TreeItem<TracNghiem> item = treeTracNghiem.getSelectionModel().getSelectedItem();
		if (item != null) {
			TracNghiem tracNghiem = item.getValue();
			ChinhSuaTracNghiemController chinhSuaTracNghiem = loader.getController();
			chinhSuaTracNghiem.setTextMonHoc(tracNghiem.getMonHoc());
			chinhSuaTracNghiem.setTableChuong(tracNghiem.getChuong());
			chinhSuaTracNghiem.setSliderDoKho(tracNghiem.getDoKho());
			chinhSuaTracNghiem.setAreaDeBai(tracNghiem.getDeBai());
			chinhSuaTracNghiem.setTableDapAn(tracNghiem.getDsDapAn());
			stage.showAndWait();
			tracNghiem = chinhSuaTracNghiem.chinhSuaTracNghiem();
			boolean check = true;
			if (tracNghiem.getMonHoc().equals("")) {
				check = false;
			}
			if (tracNghiem.getChuong().isEmpty()) {
				check = false;
			}
			if (tracNghiem.getDoKho().charAt(0) == '0') {
				check = false;
			}
			if (tracNghiem.getDeBai().equals("")) {
				check = false;
			}
			if (tracNghiem.getDsDapAn().size() == 0) {
				check = false;
			}
			if (check) {
				dao.xoaTracNghiem(Integer.parseInt(item.getValue().getId()));
				treeTracNghiem.getRoot().getChildren().remove(item);
				dao.themTracNghiem(tracNghiem);
				tracNghiem.setId(dao.getLastIDTracNghiem());
				Image image = new Image(getClass().getResourceAsStream("/icon/CauHoi.png"));
				treeTracNghiem.getRoot().getChildren().add(new TreeItem<TracNghiem>(tracNghiem, new ImageView(image)));
				textMonHoc.setText("");
				listChuong.getItems().clear();
				sliderDoKho.setValue(0);
				areaDeBai.setText("");
				dsDapAn.clear();
			}
		}
	}

	/**
	 * Hiển thị giao diện Tạo đề thi bằng tay
	 * 
	 * @param event Khi người dùng chọn Menu Đề thi và chọn Tạo bằng tay
	 * @throws IOException IOException
	 */
	public void taoDeThiBangTay(ActionEvent event) throws IOException {
		FXMLLoader loader = new FXMLLoader();
		loader.setLocation(getClass().getResource("/fxml_file/TaoDeThiBangTay.fxml"));
		Stage stage = new Stage();
		Scene scene = new Scene(loader.load());
		stage.getIcons().add(new Image("/icon/iconWindows.png"));
		stage.setTitle("Tạo đê thi băng tay");
		stage.initModality(Modality.WINDOW_MODAL);
		stage.initOwner(areaDeBai.getScene().getWindow());
		stage.setResizable(false);
		stage.setScene(scene);
		stage.show();
	}

	/**
	 * Hiển thị giao diện tạo đề thi ngẫu nhiên
	 * 
	 * @param event Khi người dùng chọn Menu Đề thi và chọn Tạo ngẫu nhiên
	 * @throws IOException IOException
	 */
	public void taoDeThiNgauNhien(ActionEvent event) throws IOException {
		FXMLLoader loader = new FXMLLoader();
		loader.setLocation(getClass().getResource("/fxml_file/TaoDeThiNgauNhien.fxml"));
		Stage stage = new Stage();
		Scene scene = new Scene(loader.load());
		stage.setTitle("Tạo đề thi ngẫu nhiên");
		stage.initModality(Modality.WINDOW_MODAL);
		stage.initOwner(areaDeBai.getScene().getWindow());
		stage.setResizable(false);
		stage.setScene(scene);
		stage.getIcons().add(new Image("/icon/iconWindows.png"));
		stage.show();
	}

	/**
	 * Hiển thị giao diện Thông tin phần mềm
	 * 
	 * @param event Khi người dùng chọn Menu Trợ giúp và chọn Thông tin
	 * @throws IOException IOException
	 */
	public void xemThongTin(ActionEvent event) throws IOException {
		FXMLLoader loader = new FXMLLoader();
		loader.setLocation(getClass().getResource("/fxml_file/ThongTin.fxml"));
		Stage stage = new Stage();
		Scene scene = new Scene(loader.load());
		stage.setTitle("Thông tin");
		stage.initModality(Modality.WINDOW_MODAL);
		stage.initOwner(areaDeBai.getScene().getWindow());
		stage.setResizable(false);
		stage.setScene(scene);
		stage.getIcons().add(new Image("/icon/iconWindows.png"));
		stage.show();
	}

	/**
	 * Hiển thị file Hướng dẫn sử dụng.pdf
	 * 
	 * @param event Khi người dùng chọn Menu Trợ giúp và chọn Hướng dẫn sử dụng
	 * @throws IOException IOException
	 */
	public void huongDanSuDung(ActionEvent event) throws IOException {
		File file = new File("huongDan.pdf");
		Desktop desktop = Desktop.getDesktop();
		if (file.exists()) {
			desktop.open(file);
		}
	}
}
