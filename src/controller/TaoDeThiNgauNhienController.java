package controller;

import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.sql.SQLException;
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
import javafx.scene.control.TextField;
import javafx.scene.control.TreeItem;
import javafx.scene.control.TreeView;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.stage.Stage;
import set_class.DapAnTracNghiem;
import set_class.TracNghiem;
import set_class.TuLuan;

/**
 * Class chứa các hàm giúp tạo đề thi ngẫu nhiên và điều khiển các thành phần
 * giao diện trong file fxml: TaoDeThiNgauNhien.fxml
 * 
 * @author Hoàng Hải Đăng
 */
public class TaoDeThiNgauNhienController implements Initializable {
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
	private Button buttonTaoDeThi;

	@FXML
	private TextField textSoLuong;

	@FXML
	private ChoiceBox<String> choiceBoxDoKho;

	@FXML
	private ChoiceBox<String> choiceBoxBoTri;
	private DAO dao = new DAO();
	private ArrayList<TuLuan> dsTuLuan = dao.getDsTuLuan();
	private ArrayList<TracNghiem> dsTracNghiem = dao.getDsTracNghiem();

	/**
	 * Cài đặt các giá trị ban đầu cho các thành phần giao diện
	 */
	@Override
	public void initialize(URL location, ResourceBundle resources) {
		Image imageMonHoc = new Image(getClass().getResourceAsStream("/icon/MonHoc.png"));
		Image imageChuong = new Image(getClass().getResourceAsStream("/icon/Chuong.png"));
		TreeItem<String> itemRoot = new TreeItem<String>();
		try {
			ArrayList<String> dsMonHoc = dao.getDsMonHoc();
			for (int i = 0; i < dsMonHoc.size(); i++) {
				String monHoc = dsMonHoc.get(i);
				TreeItem<String> itemMonHoc = new TreeItem<String>(monHoc, new ImageView(imageMonHoc));
				ArrayList<String> dsChuong = dao.getDsChuong(monHoc);
				for (int j = 0; j < dsChuong.size(); j++) {
					itemMonHoc.getChildren().add(new TreeItem<String>(dsChuong.get(j), new ImageView(imageChuong)));
				}
				itemRoot.getChildren().add(itemMonHoc);

			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		treeChuaChon.setRoot(itemRoot);
		treeChuaChon.setShowRoot(false);
		itemRoot = new TreeItem<String>();
		treeDaChon.setRoot(itemRoot);
		treeDaChon.setShowRoot(false);
		choiceBoxDoKho.setItems(
				FXCollections.observableArrayList("Bất kỳ", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"));
		choiceBoxBoTri
				.setItems(FXCollections.observableArrayList("Gồm 2 phần tự luận và trắc nghiệm", "Trộn lẫn 2 phần"));
	}

	/**
	 * Khi người dùng chọn một chương trong danh sách các chương hiện có và nhấn
	 * Thêm thì chương đó sẽ được thêm vào danh sách các chương đã chọn
	 * 
	 * @param event Khi người dùng chọn một chương trong danh sách các chương hiện
	 *              có và nhấn Thêm
	 */
	public void themChuong(ActionEvent event) {
		TreeItem<String> item = treeChuaChon.getSelectionModel().getSelectedItem();
		Image imageChuong = new Image(getClass().getResourceAsStream("/icon/Chuong.png"));
		Image imageMonHoc = new Image(getClass().getResourceAsStream("/icon/MonHoc.png"));
		if ((item != null) && (treeChuaChon.getRoot().getChildren().size() != 0)) {
			if (item.getParent() == treeChuaChon.getRoot()) {
				ObservableList<TreeItem<String>> dsItemDaChon = treeDaChon.getRoot().getChildren();
				String itemStr = item.getValue();
				treeChuaChon.getRoot().getChildren().remove(item);
				boolean check = false;
				for (int i = 0; i < dsItemDaChon.size(); i++) {
					if (dsItemDaChon.get(i).getValue().equals(itemStr)) {
						check = true;
						ObservableList<TreeItem<String>> dsSubItem = item.getChildren();
						for (int j = 0; j < dsSubItem.size(); j++) {
							treeDaChon.getRoot().getChildren().get(i).getChildren().add(dsSubItem.get(j));
						}
						break;
					}
				}
				if (!check) {
					treeDaChon.getRoot().getChildren().add(item);
				}

			} else {
				ObservableList<TreeItem<String>> dsItemDaChon = treeDaChon.getRoot().getChildren();
				String parentItemStr = item.getParent().getValue();
				String itemStr = item.getValue();
				if (item.getParent().getChildren().size() == 1) {
					treeChuaChon.getRoot().getChildren().remove(item.getParent());
				} else {
					treeChuaChon.getSelectionModel().getSelectedItem().getParent().getChildren().remove(item);
				}
				boolean check = false;
				for (int i = 0; i < dsItemDaChon.size(); i++) {
					if (dsItemDaChon.get(i).getValue().equals(parentItemStr)) {
						check = true;
						treeDaChon.getRoot().getChildren().get(i).getChildren()
								.add(new TreeItem<String>(itemStr, new ImageView(imageChuong)));
						break;
					}
				}
				if (!check) {
					TreeItem<String> itemParent = new TreeItem<String>(parentItemStr, new ImageView(imageMonHoc));
					itemParent.getChildren().add(new TreeItem<String>(itemStr, new ImageView(imageChuong)));
					treeDaChon.getRoot().getChildren().add(itemParent);
				}
			}
		}
	}

	/**
	 * Khi người dùng chọn một chương trong danh sách các chương đã chọn và nhấn
	 * Loại bỏ, chương đó sẽ được thêm vào danh sách các chương hiện có
	 * 
	 * @param event Khi người dùng chọn một chương trong danh sách các chương đã
	 *              chọn và nhấn Loại bỏ
	 */
	public void loaiBoChuong(ActionEvent event) {
		Image imageChuong = new Image(getClass().getResourceAsStream("/icon/Chuong.png"));
		Image imageMonHoc = new Image(getClass().getResourceAsStream("/icon/MonHoc.png"));
		TreeItem<String> item = treeDaChon.getSelectionModel().getSelectedItem();
		if ((item != null) && (treeDaChon.getRoot().getChildren().size() != 0)) {
			if (item.getParent() == treeDaChon.getRoot()) {
				ObservableList<TreeItem<String>> dsItemChuaChon = treeChuaChon.getRoot().getChildren();
				String itemStr = item.getValue();
				treeDaChon.getRoot().getChildren().remove(item);
				boolean check = false;
				for (int i = 0; i < dsItemChuaChon.size(); i++) {
					if (dsItemChuaChon.get(i).getValue().equals(itemStr)) {
						check = true;
						ObservableList<TreeItem<String>> dsSubItem = item.getChildren();
						for (int j = 0; j < dsSubItem.size(); j++) {
							treeChuaChon.getRoot().getChildren().get(i).getChildren().add(dsSubItem.get(j));
						}
						break;
					}
				}
				if (!check) {
					treeChuaChon.getRoot().getChildren().add(item);
				}

			} else {
				ObservableList<TreeItem<String>> dsItemChuaChon = treeChuaChon.getRoot().getChildren();
				String parentItemStr = item.getParent().getValue();
				String itemStr = item.getValue();
				if (item.getParent().getChildren().size() == 1) {
					treeDaChon.getRoot().getChildren().remove(item.getParent());
				} else {
					treeDaChon.getSelectionModel().getSelectedItem().getParent().getChildren().remove(item);
				}
				boolean check = false;
				for (int i = 0; i < dsItemChuaChon.size(); i++) {
					if (dsItemChuaChon.get(i).getValue().equals(parentItemStr)) {
						check = true;
						treeChuaChon.getRoot().getChildren().get(i).getChildren()
								.add(new TreeItem<String>(itemStr, new ImageView(imageChuong)));
						break;
					}
				}
				if (!check) {
					TreeItem<String> itemParent = new TreeItem<String>(parentItemStr, new ImageView(imageMonHoc));
					itemParent.getChildren().add(new TreeItem<String>(itemStr, new ImageView(imageChuong)));
					treeChuaChon.getRoot().getChildren().add(itemParent);
				}
			}
		}
	}

	/**
	 * Tạo file PDF đề thi đồng thời hiện thông báo đã tạo đề thi thành công
	 * 
	 * @param event Khi người dùng nhấn Tạo đề thi
	 * @throws SQLException SQLException
	 * @throws DocumentException DocumentException
	 * @throws IOException IOException
	 */
	public void taoDeThi(ActionEvent event) throws SQLException, DocumentException, IOException {
		ObservableList<TreeItem<String>> dsItemDaChon = treeDaChon.getRoot().getChildren();
		ArrayList<String> dsChuong = new ArrayList<String>();
		for (TreeItem<String> itemDaChon : dsItemDaChon) {
			ObservableList<TreeItem<String>> item = itemDaChon.getChildren();
			for (int i = 0; i < item.size(); i++) {
				dsChuong.add(item.get(i).getValue());
			}
		}
		ArrayList<String> dsID = new ArrayList<String>();
		if (choiceBoxDoKho.getValue() != null) {
			if (choiceBoxDoKho.getValue().equals("Bất kỳ")) {
				for (String chuong : dsChuong) {
					ArrayList<String> id = dao.getDsID(chuong);
					if (dsID.size() != 0) {
						for (int i = 0; i < id.size(); i++) {
							boolean check = true;
							for (int j = 0; j < dsID.size(); j++) {
								if (dsID.get(j).equals(id.get(i))) {
									check = false;
									break;
								}
							}
							if (check) {
								dsID.add(id.get(i));
							}
						}
					} else {
						dsID.addAll(id);
					}
				}
			} else {
				for (String chuong : dsChuong) {
					ArrayList<String> id = dao.getDsIDDoKho(chuong, choiceBoxDoKho.getValue() + ".0/10");
					if (dsID.size() != 0) {
						for (int i = 0; i < id.size(); i++) {
							boolean check = true;
							for (int j = 0; j < dsID.size(); j++) {
								if (dsID.get(j).equals(id.get(i))) {
									check = false;
									break;
								}
							}
							if (check) {
								dsID.add(id.get(i));
							}
						}
					} else {
						dsID.addAll(id);
					}
				}
			}
			int soLuong = 0;
			boolean check = true;
			try {
				soLuong = Integer.parseInt(textSoLuong.getText());
				if (soLuong <= 0) {
					check = false;
					Alert alert = new Alert(Alert.AlertType.WARNING);
					alert.setTitle("Cảnh báo !");
					((Stage) alert.getDialogPane().getScene().getWindow()).getIcons()
							.add(new Image("/icon/warning.png"));
					alert.setHeaderText(null);
					alert.setContentText("Số lượng câu hỏi phải là một số nguyên dương");
					alert.showAndWait();
				}
				if (soLuong > dsID.size()) {
					check = false;
					Alert alert = new Alert(Alert.AlertType.WARNING);
					alert.setHeaderText(null);
					alert.setTitle("Cảnh báo !");
					((Stage) alert.getDialogPane().getScene().getWindow()).getIcons()
							.add(new Image("/icon/warning.png"));
					alert.setContentText(
							"Không đủ số lượng câu hỏi để tạo đề thi\n Số lượng câu hỏi tối đa là: " + dsID.size());
					alert.showAndWait();
				}
			} catch (NumberFormatException e) {
				check = false;
				Alert alert = new Alert(Alert.AlertType.WARNING);
				alert.setHeaderText(null);
				alert.setTitle("Cảnh báo !");
				((Stage) alert.getDialogPane().getScene().getWindow()).getIcons().add(new Image("/icon/warning.png"));
				alert.setContentText("Số lượng câu hỏi phải là một số nguyên dương");
				alert.showAndWait();
			}

			if (treeDaChon.getRoot().getChildren().size() != 0) {
				if (check) {
					int soLuongCanBo = dsID.size() - soLuong;
					Random random = new Random();
					for (int i = 0; i < soLuongCanBo; i++) {
						int viTriBo = random.nextInt(dsID.size());
						dsID.remove(viTriBo);
					}

					Document document = new Document();
					PdfWriter.getInstance(document, new FileOutputStream("DeThi.pdf"));
					document.open();
					Font fontTimes = new Font(
							BaseFont.createFont("/font/times.ttf", BaseFont.IDENTITY_H, BaseFont.EMBEDDED));
					Font fontTimesBold = new Font(
							BaseFont.createFont("/font/timesbi.ttf", BaseFont.IDENTITY_H, BaseFont.EMBEDDED));
					if (choiceBoxBoTri.getValue() != null) {
						if (choiceBoxBoTri.getValue() == "Trộn lẫn 2 phần") {
							int dem = 1;
							for (String str : dsID) {
								int id = Integer.parseInt(str);
								if (id % 2 == 0) {
									for (TracNghiem tracNghiem : dsTracNghiem) {
										if (tracNghiem.getId().equals(str)) {
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
										if (tuLuan.getId().equals(str)) {
											para.add(new Phrase(tuLuan.getDeBai(), fontTimes));
											dem++;
											break;
										}
									}
									document.add(para);
								}
							}
							document.close();
							Alert alert = new Alert(Alert.AlertType.INFORMATION);
							alert.setContentText("Đã tạo file PDF");
							alert.setHeaderText(null);
							alert.setTitle("Thông báo");
							((Stage) alert.getDialogPane().getScene().getWindow()).getIcons()
									.add(new Image("/icon/info.png"));
							alert.showAndWait();
							((Stage) buttonTaoDeThi.getScene().getWindow()).close();
						} else {
							int dem = 1;
							check = true;
							for (String str : dsID) {
								int id = Integer.parseInt(str);
								if (id % 2 == 0) {
									if (check) {
										document.add(new Paragraph("PHẦN I: PHẦN TRẮC NGHIỆM", fontTimesBold));
										check = false;
									}
									for (TracNghiem tracNghiem : dsTracNghiem) {
										if (tracNghiem.getId().equals(str)) {
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
								}
							}
							dem = 1;
							check = true;
							for (String str : dsID) {
								int id = Integer.parseInt(str);
								if (id % 2 != 0) {
									if (check) {
										document.add(new Paragraph("PHẦN II: PHẦN TỰ LUẬN", fontTimesBold));
										check = false;
									}
									Paragraph para = new Paragraph();
									para.add(new Phrase("Câu " + dem + ": ", fontTimesBold));
									for (TuLuan tuLuan : dsTuLuan) {
										if (tuLuan.getId().equals(str)) {
											para.add(new Phrase(tuLuan.getDeBai(), fontTimes));
											dem++;
											break;
										}
									}
									document.add(para);
								}
							}
							document.close();
							Alert alert = new Alert(Alert.AlertType.INFORMATION);
							alert.setContentText("Đã tạo file PDF");
							alert.setTitle("Thông báo");
							((Stage) alert.getDialogPane().getScene().getWindow()).getIcons()
									.add(new Image("/icon/info.png"));
							alert.setHeaderText(null);
							alert.showAndWait();
							((Stage) buttonTaoDeThi.getScene().getWindow()).close();
						}
					} else {
						Alert alert = new Alert(Alert.AlertType.WARNING);
						alert.setHeaderText(null);
						alert.setTitle("Cảnh báo !");
						((Stage) alert.getDialogPane().getScene().getWindow()).getIcons()
								.add(new Image("/icon/warning.png"));
						alert.setContentText("Không được để trống phần chọn bố cục đề thi");
						alert.showAndWait();
					}
				}
			} else {
				Alert alert = new Alert(Alert.AlertType.WARNING);
				alert.setHeaderText(null);
				alert.setTitle("Cảnh báo !");
				((Stage) alert.getDialogPane().getScene().getWindow()).getIcons().add(new Image("/icon/warning.png"));
				alert.setContentText("Chưa chọn danh sách các chương");
				alert.showAndWait();
			}
		} else {
			Alert alert = new Alert(Alert.AlertType.WARNING);
			alert.setHeaderText(null);
			alert.setTitle("Cảnh báo !");
			((Stage) alert.getDialogPane().getScene().getWindow()).getIcons().add(new Image("/icon/warning.png"));
			alert.setContentText("Chưa chọn độ khó cho đề thi");
			alert.showAndWait();
		}
	}

	/**
	 * Đóng giao diện Tạo đề thi ngẫu nhiên đồng thời hủy bỏ việc tạo đề thi ngẫu
	 * nhiên
	 * 
	 * @param event Khi người dùng nhấn Hủy bỏ
	 */
	public void huyBo(ActionEvent event) {
		Stage stage = (Stage) buttonHuyBo.getScene().getWindow();
		stage.close();
	}
}
