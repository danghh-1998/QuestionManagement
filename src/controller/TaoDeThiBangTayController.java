package controller;

import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Random;
import java.util.ResourceBundle;

import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Font;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.BaseFont;
import com.itextpdf.text.pdf.PdfWriter;

import database_access_object.DAO;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.ChoiceBox;
import javafx.scene.control.TreeItem;
import javafx.scene.control.TreeView;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.stage.Stage;
import set_class.DapAnTracNghiem;
import set_class.TracNghiem;
import set_class.TuLuan;

/**
 * Class chứa các hàm giúp tạo đề thi bằng tay và điều khiển các thành phần giao
 * diện trong file fxml: TaoDeThiBangTay.fxml
 * 
 * @author Hoàng Hải Đăng
 */
public class TaoDeThiBangTayController implements Initializable {
	@FXML
	private Button buttonLoaiBo;

	@FXML
	private Button buttonThem;

	@FXML
	private TreeView<String> treeDaChon;

	@FXML
	private TreeView<String> treeChuaChon;

	@FXML
	private Button buttonHuyBo;

	@FXML
	private ChoiceBox<String> choiceBoxBoTri;

	@FXML
	private Button buttonTaoDeThi;
	private DAO dao = new DAO();
	private ArrayList<TuLuan> dsTuLuan = dao.getDsTuLuan();
	private ArrayList<TracNghiem> dsTracNghiem = dao.getDsTracNghiem();

	/**
	 * Cài đặt các giá trị ban đầu cho các thành phần giao diện
	 */
	@Override
	public void initialize(URL location, ResourceBundle resources) {
		TreeItem<String> itemRoot = new TreeItem<String>();
		Image imageMonHoc = new Image(getClass().getResourceAsStream("/icon/MonHoc.png"));
		Image imageChuong = new Image(getClass().getResourceAsStream("/icon/Chuong.png"));
		Image imageDapAn = new Image(getClass().getResourceAsStream("/icon/DapAn.png"));
		Image imageDapAnDung = new Image(getClass().getResourceAsStream("/icon/DapAnDung.png"));
		Image imageDeBai = new Image(getClass().getResourceAsStream("/icon/DeBai.png"));
		Image imageDoKho = new Image(getClass().getResourceAsStream("/icon/DoKho.png"));
		Image imageID = new Image(getClass().getResourceAsStream("/icon/ID.png"));
		for (int i = 0; i < dsTuLuan.size(); i++) {
			TuLuan tuLuan = dsTuLuan.get(i);
			TreeItem<String> itemID = new TreeItem<String>(tuLuan.getId(), new ImageView(imageID));
			TreeItem<String> itemMonHoc = new TreeItem<String>("Môn Học", new ImageView(imageMonHoc));
			itemMonHoc.getChildren().add(new TreeItem<String>(tuLuan.getMonHoc()));
			itemID.getChildren().add(itemMonHoc);
			TreeItem<String> itemChuong = new TreeItem<String>("Chương", new ImageView(imageChuong));
			ArrayList<String> dsChuong = tuLuan.getChuong();
			for (int j = 0; j < dsChuong.size(); j++) {
				itemChuong.getChildren().add(new TreeItem<String>(dsChuong.get(j)));
			}
			itemID.getChildren().add(itemChuong);
			TreeItem<String> itemDoKho = new TreeItem<String>("Độ khó", new ImageView(imageDoKho));
			itemDoKho.getChildren().add(new TreeItem<String>(tuLuan.getDoKho()));
			itemID.getChildren().add(itemDoKho);
			TreeItem<String> itemDeBai = new TreeItem<String>("Đề bài", new ImageView(imageDeBai));
			itemDeBai.getChildren().add(new TreeItem<String>(tuLuan.getDeBai()));
			itemID.getChildren().add(itemDeBai);
			TreeItem<String> itemDapAn = new TreeItem<String>("Đáp án", new ImageView(imageDapAnDung));
			itemDapAn.getChildren().add(new TreeItem<String>(tuLuan.getDapAn()));
			itemID.getChildren().add(itemDapAn);
			itemRoot.getChildren().add(itemID);
		}
		treeChuaChon.setRoot(itemRoot);
		treeChuaChon.setShowRoot(false);
		for (int i = 0; i < dsTracNghiem.size(); i++) {
			TracNghiem tracNghiem = dsTracNghiem.get(i);
			TreeItem<String> itemID = new TreeItem<String>(tracNghiem.getId(), new ImageView(imageID));
			TreeItem<String> itemMonHoc = new TreeItem<String>("Môn học", new ImageView(imageMonHoc));
			itemMonHoc.getChildren().add(new TreeItem<String>(tracNghiem.getMonHoc()));
			itemID.getChildren().add(itemMonHoc);
			TreeItem<String> itemChuong = new TreeItem<String>("Chương", new ImageView(imageChuong));
			ArrayList<String> dsChuong = tracNghiem.getChuong();
			for (int j = 0; j < dsChuong.size(); j++) {
				itemChuong.getChildren().add(new TreeItem<String>(dsChuong.get(j)));
			}
			itemID.getChildren().add(itemChuong);
			TreeItem<String> itemDoKho = new TreeItem<String>("Độ khó", new ImageView(imageDoKho));
			itemDoKho.getChildren().add(new TreeItem<String>(tracNghiem.getDoKho()));
			itemID.getChildren().add(itemDoKho);
			TreeItem<String> itemDeBai = new TreeItem<String>("Đề bài", new ImageView(imageDeBai));
			itemDeBai.getChildren().add(new TreeItem<String>(tracNghiem.getDeBai()));
			itemID.getChildren().add(itemDeBai);
			TreeItem<String> itemDapAn = new TreeItem<String>("Danh sách đáp án", new ImageView(imageDapAn));
			ArrayList<DapAnTracNghiem> dsDapAn = tracNghiem.getDsDapAn();
			for (int j = 0; j < dsDapAn.size(); j++) {
				itemDapAn.getChildren().add(new TreeItem<String>(dsDapAn.get(j).getDapAn()));
			}
			itemID.getChildren().add(itemDapAn);
			TreeItem<String> itemDapAnDung = new TreeItem<String>("Danh sách đáp án đúng",
					new ImageView(imageDapAnDung));
			for (int j = 0; j < dsDapAn.size(); j++) {
				DapAnTracNghiem dapAnTracNghiem = dsDapAn.get(j);
				if (dapAnTracNghiem.isDungSai()) {
					itemDapAnDung.getChildren().add(new TreeItem<String>(dapAnTracNghiem.getDapAn()));
				}
			}
			itemID.getChildren().add(itemDapAnDung);
			itemRoot.getChildren().add(itemID);
		}
		itemRoot = new TreeItem<String>("");
		treeDaChon.setRoot(itemRoot);
		treeDaChon.setShowRoot(false);
		choiceBoxBoTri
				.setItems(FXCollections.observableArrayList("Gồm 2 phần tự luận và trắc nghiệm", "Trộn lẫn 2 phần"));
	}

	/**
	 * Khi lựa chọn một câu hỏi trong danh sách các câu hỏi hiện có sau đó nhấn Thêm
	 * câu hỏi đó sẽ được thêm trong danh sách các câu hỏi đã chọn
	 * 
	 * @param event Khi lựa chọn một câu hỏi trong danh sách các câu hỏi hiện có sau
	 *              đó nhấn Thêm
	 */
	public void themCauHoi(ActionEvent event) {
		TreeItem<String> item = treeChuaChon.getSelectionModel().getSelectedItem();
		if (item != null) {
			if (item.getParent() == treeChuaChon.getRoot()) {
				treeChuaChon.getRoot().getChildren().remove(item);
				treeDaChon.getRoot().getChildren().add(item);
			}
		}
	}

	/**
	 * Khi lụa chọn một câu hỏi trong danh sách câu hỏi đã chọn sau đó nhấn Loại bỏ
	 * câu hỏi đó sẽ được thêm trong danh sách câu hỏi hiện có
	 * 
	 * @param event Khi lụa chọn một câu hỏi trong danh sách câu hỏi đã chọn sau đó
	 *              nhấn Loại bỏ
	 */
	public void loaiBoCauHoi(ActionEvent event) {
		TreeItem<String> item = treeDaChon.getSelectionModel().getSelectedItem();
		if (item != null) {
			if (item.getParent() == treeDaChon.getRoot()) {
				treeDaChon.getRoot().getChildren().remove(item);
				treeChuaChon.getRoot().getChildren().add(item);
			}
		}
	}

	/**
	 * Tắt cửa sổ Tạo đề thi bằng tay đồng thời hủy bỏ việc tạo đề thi bằng tay
	 * 
	 * @param event Khi người dùng nhấn Hủy bỏ
	 */
	public void huyBo(ActionEvent event) {
		Stage stage = (Stage) buttonHuyBo.getScene().getWindow();
		stage.close();
	}

	/**
	 * Tạo file PDF chứa đề thi từ các câu hỏi đã được người dùng chọn, đồng thời
	 * hiện thông báo đã tạo đề thi thành công
	 * 
	 * @param event Khi người dùng nhấn Tạo đề thi
	 * @throws DocumentException DocumentException
	 * @throws IOException IOException
	 */
	public void taoDeThi(ActionEvent event) throws DocumentException, IOException {
		Document document = new Document();
		PdfWriter.getInstance(document, new FileOutputStream("DeThi.pdf"));
		document.open();
		Font fontTimes = new Font(BaseFont.createFont("/font/times.ttf", BaseFont.IDENTITY_H, BaseFont.EMBEDDED));
		Font fontTimesBold = new Font(BaseFont.createFont("/font/timesbi.ttf", BaseFont.IDENTITY_H, BaseFont.EMBEDDED));
		ObservableList<TreeItem<String>> dsItem = treeDaChon.getRoot().getChildren();
		if (treeDaChon.getRoot().getChildren().size() != 0) {
			if (!(choiceBoxBoTri.getValue() == null)) {
				if (choiceBoxBoTri.getValue().equals("Trộn lẫn 2 phần")) {
					int dem = 1;
					Random random = new Random();
					for (TreeItem<String> item : dsItem) {
						int id = Integer.parseInt(item.getValue());
						if (id % 2 == 0) {
							for (TracNghiem tracNghiem : dsTracNghiem) {
								if (tracNghiem.getId().equals(item.getValue())) {
									Paragraph para = new Paragraph();
									para.add(new Phrase("Câu " + dem + ": ", fontTimesBold));
									para.add(new Phrase(tracNghiem.getDeBai(), fontTimes));
									document.add(para);
									char ch = 'A';
									ArrayList<DapAnTracNghiem> dsDapAn = tracNghiem.getDsDapAn();
									int soLuongDapAn = dsDapAn.size();
									for (int i = 0; i < soLuongDapAn; i++) {
										para = new Paragraph();
										para.add(new Phrase((char) (ch + i) + ". ", fontTimesBold));
										int viTri = random.nextInt(dsDapAn.size());
										para.add(new Phrase(dsDapAn.get(viTri).getDapAn(), fontTimes));
										document.add(para);
										dsDapAn.remove(viTri);
									}
									dem++;
									break;
								}
							}
						} else {
							Paragraph para = new Paragraph();
							para.add(new Phrase("Câu " + dem + ": ", fontTimesBold));
							for (TuLuan tuLuan : dsTuLuan) {
								if (tuLuan.getId().equals(item.getValue())) {
									para.add(new Phrase(tuLuan.getDeBai(), fontTimes));
									dem++;
									break;
								}
							}
							document.add(para);
						}
					}
				} else {
					int dem = 1;
					Random random = new Random();
					boolean check = true;
					for (int i = 0; i < dsItem.size(); i++) {
						TreeItem<String> item = dsItem.get(i);
						int id = Integer.parseInt(item.getValue());
						if (id % 2 == 0) {
							if (check) {
								document.add(new Paragraph("PHẦN I: PHẦN TRẮC NGHIỆM", fontTimesBold));
								check = false;
							}
							for (TracNghiem tracNghiem : dsTracNghiem) {
								if (tracNghiem.getId().equals(item.getValue())) {
									Paragraph para = new Paragraph();
									para.add(new Phrase("Câu " + dem + ": ", fontTimesBold));
									para.add(new Phrase(tracNghiem.getDeBai(), fontTimes));
									document.add(para);
									char ch = 'A';
									ArrayList<DapAnTracNghiem> dsDapAn = tracNghiem.getDsDapAn();
									int soLuongDapAn = dsDapAn.size();
									for (int j = 0; j < soLuongDapAn; j++) {
										para = new Paragraph();
										para.add(new Phrase((char) (ch + j) + ". ", fontTimesBold));
										int viTri = random.nextInt(dsDapAn.size());
										para.add(new Phrase(dsDapAn.get(viTri).getDapAn(), fontTimes));
										document.add(para);
										dsDapAn.remove(viTri);
									}
									dem++;
									break;
								}
							}
						}
					}
					check = true;
					dem = 1;
					for (int i = 0; i < dsItem.size(); i++) {
						TreeItem<String> item = dsItem.get(i);
						int id = Integer.parseInt(item.getValue());
						if (id % 2 != 0) {
							if (check) {
								document.add(new Paragraph("PHẦN II: PHẦN TỰ LUẬN", fontTimesBold));
								check = false;
							}
							Paragraph para = new Paragraph();
							para.add(new Phrase("Câu " + dem + ": ", fontTimesBold));
							for (TuLuan tuLuan : dsTuLuan) {
								if (tuLuan.getId().equals(item.getValue())) {
									para.add(new Phrase(tuLuan.getDeBai(), fontTimes));
									dem++;
									break;
								}
							}
							document.add(para);
						}
					}
				}
				document.close();
				Alert alert = new Alert(Alert.AlertType.INFORMATION);
				alert.setContentText("Đã tạo file PDF");
				alert.setHeaderText(null);
				alert.setTitle("Thông báo");
				((Stage) alert.getDialogPane().getScene().getWindow()).getIcons().add(new Image("/icon/info.png"));
				alert.showAndWait();
				((Stage) buttonTaoDeThi.getScene().getWindow()).close();
			} else {
				Alert alert = new Alert(Alert.AlertType.WARNING);
				alert.setHeaderText(null);
				alert.setTitle("Cảnh báo !");
				((Stage) alert.getDialogPane().getScene().getWindow()).getIcons().add(new Image("/icon/warning.png"));
				alert.setContentText("Không được để trống phần chọn bố cục đề thi");
				alert.showAndWait();
			}
		} else {
			Alert alert = new Alert(Alert.AlertType.WARNING);
			alert.setHeaderText(null);
			alert.setTitle("Cảnh báo !");
			((Stage) alert.getDialogPane().getScene().getWindow()).getIcons().add(new Image("/icon/warning.png"));
			alert.setContentText("Chưa chọn danh sách câu hỏi");
			alert.showAndWait();
		}
	}

}
