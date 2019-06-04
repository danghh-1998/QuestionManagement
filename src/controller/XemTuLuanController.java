package controller;

import java.awt.Desktop;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.ResourceBundle;

import database_access_object.DAO;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.ListView;
import javafx.scene.control.MenuItem;
import javafx.scene.control.Slider;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.control.TreeItem;
import javafx.scene.control.TreeView;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseButton;
import javafx.scene.input.MouseEvent;
import javafx.stage.Modality;
import javafx.stage.Stage;
import set_class.TuLuan;

/**
 * Class chứa các hàm cho phép hiển thị danh sách các câu hỏi tự luận, hiển thị
 * giao diện thêm, sửa xóa câu hỏi tự luận, giao diện tạo đề thi bằng tay hoặc
 * ngẫu nhiên, hiển thị thông tin ứng dụng, hướng dẫn sử dụng đồng thời điều
 * khiển các thành phần giao diện trong file fxml: XemTuLuan.fxml
 * 
 * @author Hoàng Hải Đăng
 */
public class XemTuLuanController implements Initializable {
	@FXML
	private TextArea areaDeBai;

	@FXML
	private MenuItem menuItemTuLuan;

	@FXML
	private MenuItem menuItemTaoDeThiBangTay;

	@FXML
	private TextField textMonHoc;

	@FXML
	private Slider sliderDoKho;

	@FXML
	private TextArea areaDapAn;

	@FXML
	private ListView<String> listChuong;

	@FXML
	private MenuItem menuItemTracNghiem;

	@FXML
	private TreeView<TuLuan> treeTuLuan;

	@FXML
	private MenuItem contextThemTuLuan;

	@FXML
	private MenuItem menuItemTaoDeThiNgauNhien;

	@FXML
	private MenuItem menuItemThongTin;

	@FXML
	private MenuItem menuHuongDan;

	private DAO dao = new DAO();
	private ArrayList<TuLuan> dsTuLuan = dao.getDsTuLuan();
	private ObservableList<String> dsChuongHienThi = FXCollections.observableArrayList();

	/**
	 * Thiết lập các giá trị ban đầu cho các thành phần giao diện
	 */
	@Override
	public void initialize(URL location, ResourceBundle resources) {
		TreeItem<TuLuan> rootTuLuan = new TreeItem<TuLuan>();
		Image image = new Image(getClass().getResourceAsStream("/icon/CauHoi.png"));
		for (int i = 0; i < dsTuLuan.size(); i++) {
			TreeItem<TuLuan> item = new TreeItem<TuLuan>(dsTuLuan.get(i));
			item.setGraphic(new ImageView(image));
			rootTuLuan.getChildren().add(item);
		}
		treeTuLuan.setRoot(rootTuLuan);
		treeTuLuan.setShowRoot(false);
	}

	/**
	 * Thay đổi từ cửa sổ hiển thị danh sách câu hỏi trắc nghiệm sang hiển thị danh
	 * sách câu hỏi tự luận
	 * 
	 * @param event Khi người dùng chọn Menu Câu hỏi và chọn Câu hỏi trắc nghiệm
	 * @throws IOException IOException
	 */
	public void changeScene(ActionEvent event) throws IOException {
		Stage stage = (Stage) areaDeBai.getScene().getWindow();
		Parent root = FXMLLoader.load(getClass().getResource("/fxml_file/XemTracNghiem.fxml"));
		Scene scene = new Scene(root);
		stage.setScene(scene);
		stage.setTitle("Câu hỏi trắc nghiệm");
		stage.show();
	}

	/**
	 * Hiển thị giao diện Thêm câu hỏi tự luận, thêm câu hỏi tự luận vào cơ sở dữ
	 * liệu nếu câu hỏi đó có đầy đủ các thuộc tính
	 * 
	 * @param event Khi người dùng nhấn chuột phải và chọn Thêm câu hỏi
	 * @throws IOException IOException
	 * @throws SQLException SQLException
	 */
	public void themTuLuan(ActionEvent event) throws IOException, SQLException {
		FXMLLoader loader = new FXMLLoader();
		loader.setLocation(getClass().getResource("/fxml_file/ThemTuLuan.fxml"));
		Scene scene = new Scene(loader.load());
		Stage stage = new Stage();
		stage.setScene(scene);
		stage.getIcons().add(new Image("/icon/iconWindows.png"));
		stage.initModality(Modality.WINDOW_MODAL);
		stage.initOwner((Stage) areaDeBai.getScene().getWindow());
		stage.setResizable(false);
		stage.setTitle("Thêm câu hỏi tự luận");
		stage.showAndWait();
		ThemTuLuanController themTuLuanController = loader.getController();
		TuLuan tuLuan = themTuLuanController.themTuLuan();
		boolean check = true;
		if (tuLuan.getMonHoc().equals(""))
			check = false;
		if (tuLuan.getDoKho().charAt(0) == '0')
			check = false;
		if (tuLuan.getDeBai().equals(""))
			check = false;
		if (tuLuan.getDapAn().equals(""))
			check = false;
		if (tuLuan.getChuong().isEmpty())
			check = false;
		if (check) {
			dao.themTuLuan(tuLuan);
			tuLuan.setId(dao.getLastIDTuLuan());
			Image image = new Image(getClass().getResourceAsStream("/icon/CauHoi.png"));
			treeTuLuan.getRoot().getChildren().add(new TreeItem<TuLuan>(tuLuan, new ImageView(image)));
		}
	}

	/**
	 * Hiển thị chi tiết các thuộc tính của câu hỏi được chọn
	 * 
	 * @param mouseEvent Khi người dùng chọn một câu hỏi trong danh sách câu hỏi tự
	 *                   luận
	 */
	public void hienThi(MouseEvent mouseEvent) {
		if (mouseEvent.getButton() == MouseButton.PRIMARY) {
			dsChuongHienThi = FXCollections.observableArrayList();
			TreeItem<TuLuan> item = treeTuLuan.getSelectionModel().getSelectedItem();
			if (item != null) {
				TuLuan tuLuan = item.getValue();
				textMonHoc.setText(tuLuan.getMonHoc());
				dsChuongHienThi = FXCollections.observableArrayList(tuLuan.getChuong());
				sliderDoKho.setValue(Character.getNumericValue(tuLuan.getDoKho().charAt(0)));
				areaDeBai.setText(tuLuan.getDeBai());
				areaDapAn.setText(tuLuan.getDapAn());
				listChuong.setItems(dsChuongHienThi);
			}

		}
	}

	/**
	 * Xóa câu hỏi đó khỏi danh sách câu hỏi tự luận, loại bỏ câu hỏi khỏi cơ sở dữ
	 * liệu
	 * 
	 * @param event Khi người dùng chọn một câu hỏi, chuột phải và nhấn Xóa câu hỏi
	 * @throws NumberFormatException NumberFormatException
	 * @throws SQLException SQLException
	 */
	public void xoaTuLuan(ActionEvent event) throws NumberFormatException, SQLException {
		TreeItem<TuLuan> item = treeTuLuan.getSelectionModel().getSelectedItem();
		if (item != null) {
			dao.xoaTuLuan(Integer.parseInt((item.getValue().getId())));
			treeTuLuan.getRoot().getChildren().remove(item);
			textMonHoc.setText("");
			listChuong.getItems().clear();
			sliderDoKho.setValue(0);
			areaDeBai.setText("");
			areaDapAn.setText("");
		}

	}

	/**
	 * Hiển thị giao diện Chỉnh sửa câu hỏi tự luận, thay đổi giá trị các thuộc tính
	 * của câu hỏi đó trong cơ sở dữ liệu
	 * 
	 * @param event Khi người dùng chọn một câu hỏi, chuột phải và nhấn Chỉnh sửa
	 *              câu hỏi
	 * @throws IOException IOException
	 * @throws SQLException SQLException
	 */
	public void chinhSuaTuLuan(ActionEvent event) throws IOException, SQLException {
		FXMLLoader loader = new FXMLLoader();
		loader.setLocation(getClass().getResource("/fxml_file/ChinhSuaTuLuan.fxml"));
		Stage stage = new Stage();
		Scene scene = new Scene(loader.load());
		stage.setScene(scene);
		stage.getIcons().add(new Image("/icon/iconWindows.png"));
		stage.initModality(Modality.WINDOW_MODAL);
		stage.initOwner(areaDeBai.getScene().getWindow());
		stage.setResizable(false);
		stage.setTitle("Chỉnh sửa câu hỏi tự luận");
		TreeItem<TuLuan> item = treeTuLuan.getSelectionModel().getSelectedItem();
		if (item != null) {
			TuLuan tuLuan = item.getValue();
			ChinhSuaTuLuanController chinhSuaTuLuan = loader.getController();
			chinhSuaTuLuan.setTextMonHoc(tuLuan.getMonHoc());
			chinhSuaTuLuan.setTableChuong(tuLuan.getChuong());
			chinhSuaTuLuan.setSliderDoKho(tuLuan.getDoKho());
			chinhSuaTuLuan.setAreaDeBai(tuLuan.getDeBai());
			chinhSuaTuLuan.setAreaDapAn(tuLuan.getDapAn());
			stage.showAndWait();
			tuLuan = chinhSuaTuLuan.chinhSuaTuLuan();
			boolean check = true;
			if (tuLuan.getMonHoc().equals(""))
				check = false;
			if (tuLuan.getDoKho().charAt(0) == '0')
				check = false;
			if (tuLuan.getDeBai().equals(""))
				check = false;
			if (tuLuan.getDapAn().equals(""))
				check = false;
			if (tuLuan.getChuong().isEmpty())
				check = false;
			if (check) {
				dao.xoaTuLuan(Integer.parseInt((item.getValue().getId())));
				treeTuLuan.getRoot().getChildren().remove(item);
				dao.themTuLuan(tuLuan);
				tuLuan.setId(dao.getLastIDTuLuan());
				Image image = new Image(getClass().getResourceAsStream("/icon/CauHoi.png"));
				treeTuLuan.getRoot().getChildren().add(new TreeItem<TuLuan>(tuLuan, new ImageView(image)));
				textMonHoc.setText("");
				listChuong.getItems().clear();
				sliderDoKho.setValue(0);
				areaDeBai.setText("");
				areaDapAn.setText("");
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
		stage.setTitle("Tạo đê thi băng tay");
		stage.initModality(Modality.WINDOW_MODAL);
		stage.initOwner(areaDeBai.getScene().getWindow());
		stage.setResizable(false);
		stage.setScene(scene);
		stage.getIcons().add(new Image("/icon/iconWindows.png"));
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
