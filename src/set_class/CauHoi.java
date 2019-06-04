package set_class;

import java.util.ArrayList;

/**
 * Class khai báo các thuộc tính và phương thức của một câu hỏi
 * 
 * @author Hoàng Hải Đăng
 *
 */
public abstract class CauHoi {
	private String id;
	private String monHoc;
	private ArrayList<String> chuong;
	private String doKho;
	private String deBai;

	public CauHoi(String id, String monHoc, ArrayList<String> chuong, String doKho, String deBai) {
		super();
		this.id = id;
		this.monHoc = monHoc;
		this.chuong = chuong;
		this.doKho = doKho;
		this.deBai = deBai;
	}

	public CauHoi() {

	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getMonHoc() {
		return monHoc;
	}

	public void setMonHoc(String monHoc) {
		this.monHoc = monHoc;
	}

	public ArrayList<String> getChuong() {
		return chuong;
	}

	public void setChuong(ArrayList<String> chuong) {
		this.chuong = chuong;
	}

	public String getDoKho() {
		return doKho;
	}

	public void setDoKho(String doKho) {
		this.doKho = doKho;
	}

	public String getDeBai() {
		return deBai;
	}

	public void setDeBai(String deBai) {
		this.deBai = deBai;
	}

}
